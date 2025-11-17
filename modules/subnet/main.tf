locals {
  # Process public subnets with custom names support
  public_subnets = [
    for idx, subnet in var.public_subnets_cidr : {
      az   = var.availability_zones[idx % length(var.availability_zones)]  # round-robin assignment of AZs
      cidr = subnet.cidr
      name = subnet.name != null ? subnet.name : "${var.name_prefix}-public-${var.availability_zones[idx % length(var.availability_zones)]}-${idx + 1}"
    }
  ]
}

resource "aws_subnet" "public" {
  for_each = { for s in local.public_subnets : s.name => s }

  vpc_id                  = var.vpc_id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = each.value.name
    Type = "Public"
  })
}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-rt"
    Type = "Public"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.internet_gateway_id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public
  
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Network ACL for public subnets
resource "aws_network_acl" "public" {
  count  = var.enable_nacl ? 1 : 0
  vpc_id = var.vpc_id
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-nacl"
    Type = "Public"
  })
}

# Inbound rules for specific ports in public NACL
resource "aws_network_acl_rule" "public_inbound_ports" {
  for_each = var.enable_nacl ? toset([for p in var.public_nacl_inbound_ports : tostring(p)]) : []

  network_acl_id = aws_network_acl.public[0].id
  rule_number    = 100 + tonumber(each.value)
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.public_nacl_cidr
  from_port      = tonumber(each.value)
  to_port        = tonumber(each.value)
}

# Inbound rules for ephemeral ports in public NACL
resource "aws_network_acl_rule" "public_inbound_ephemeral" {
  count = var.enable_nacl && var.public_nacl_inbound_ephemeral ? 1 : 0

  network_acl_id = aws_network_acl.public[0].id
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.public_nacl_cidr
  from_port      = 1024
  to_port        = 65535
}

# Outbound rules for specific ports in public NACL
resource "aws_network_acl_rule" "public_outbound_ports" {
  for_each = var.enable_nacl ? toset([for p in var.public_nacl_outbound_ports : tostring(p)]) : []

  network_acl_id = aws_network_acl.public[0].id
  rule_number    = 300 + tonumber(each.value)
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.public_nacl_cidr
  from_port      = tonumber(each.value)
  to_port        = tonumber(each.value)
}

# Outbound rules for ephemeral ports in public NACL
resource "aws_network_acl_rule" "public_outbound_ephemeral" {
  count = var.enable_nacl && var.public_nacl_outbound_ephemeral ? 1 : 0

  network_acl_id = aws_network_acl.public[0].id
  rule_number    = 400
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.public_nacl_cidr
  from_port      = 1024
  to_port        = 65535
}

# Associate public subnets with public NACL
resource "aws_network_acl_association" "public" {
  for_each = var.enable_nacl ? aws_subnet.public : {}

  subnet_id      = each.value.id
  network_acl_id = aws_network_acl.public[0].id
}