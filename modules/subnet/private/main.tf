# Locals for subnet distribution across availability zones
locals {
  private_subnets = [
    for idx, cidr in var.private_subnets_cidr : {
      az   = var.availability_zones[idx % length(var.availability_zones)]
      cidr = cidr
      name = "${var.name_prefix}-private-${var.availability_zones[idx % length(var.availability_zones)]}-${idx + 1}"
    }
  ]
}

# Create private subnets
resource "aws_subnet" "private" {
  for_each = { for s in local.private_subnets : s.name => s }

  vpc_id            = var.vpc_id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  # Private subnets should not auto-assign public IPs
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = each.value.name
    Type = "Private"
    AZ   = each.value.az
  })
}

# Create Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.public_subnet_ids)) : 0

  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-eip-nat-${count.index + 1}"
    Type = "NAT Gateway EIP"
  })

  depends_on = [aws_subnet.private]
}

# Create NAT Gateways in public subnets
resource "aws_nat_gateway" "private" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.public_subnet_ids)) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = var.public_subnet_ids[count.index]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-gateway-${count.index + 1}"
    Type = "NAT Gateway"
  })

  depends_on = [aws_eip.nat]
}

# Create route tables for private subnets
resource "aws_route_table" "private" {
  for_each = var.enable_nat_gateway ? aws_subnet.private : { "isolated" = { name = "isolated", az = "isolated" } }

  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = var.enable_nat_gateway ? "${var.name_prefix}-rt-${each.value.availability_zone}" : "${var.name_prefix}-rt-isolated"
    Type = var.enable_nat_gateway ? "Private with NAT" : "Isolated"
  })
}

# Create routes to NAT Gateway (if enabled)
resource "aws_route" "private_nat_gateway" {
  for_each = var.enable_nat_gateway ? aws_route_table.private : {}

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.single_nat_gateway ? aws_nat_gateway.private[0].id : values(aws_nat_gateway.private)[0].id
}

# Associate private subnets with route tables
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = var.enable_nat_gateway ? aws_route_table.private[each.key].id : aws_route_table.private["isolated"].id
}

# Create Network ACL for private subnets (if enabled)
resource "aws_network_acl" "private" {
  count  = var.enable_nacl ? 1 : 0
  vpc_id = var.vpc_id
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-nacl"
    Type = "Private NACL"
  })
}

resource "aws_network_acl_rule" "private_inbound_ports" {
  for_each = var.enable_nacl ? toset([for p in var.private_nacl_inbound_ports : tostring(p)]) : []

  network_acl_id = aws_network_acl.private[0].id
  rule_number    = 100 + tonumber(each.value)
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.private_nacl_cidr
  from_port      = tonumber(each.value)
  to_port        = tonumber(each.value)
}

resource "aws_network_acl_rule" "private_inbound_ephemeral" {
  count = var.enable_nacl && var.private_nacl_inbound_ephemeral ? 1 : 0

  network_acl_id = aws_network_acl.private[0].id
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.private_nacl_cidr
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "private_outbound_ports" {
  for_each = var.enable_nacl ? toset([for p in var.private_nacl_outbound_ports : tostring(p)]) : []

  network_acl_id = aws_network_acl.private[0].id
  rule_number    = 300 + tonumber(each.value)
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"  # Allow outbound to internet for updates
  from_port      = tonumber(each.value)
  to_port        = tonumber(each.value)
}

resource "aws_network_acl_rule" "private_outbound_ephemeral" {
  count = var.enable_nacl && var.private_nacl_outbound_ephemeral ? 1 : 0

  network_acl_id = aws_network_acl.private[0].id
  rule_number    = 400
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_association" "private" {
  for_each = var.enable_nacl ? aws_subnet.private : {}

  subnet_id      = each.value.id
  network_acl_id = aws_network_acl.private[0].id
}
