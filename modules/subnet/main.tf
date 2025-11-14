locals {
  public_subnets = [
    for idx, cidr in var.public_subnets_cidr : {
      az   = var.availability_zones[idx % length(var.availability_zones)]
      cidr = cidr
      name = "${var.name_prefix}-public-${var.availability_zones[idx % length(var.availability_zones)]}-${idx + 1}"
    }
  ]
  
  private_subnets = var.create_private_subnets ? [
    for idx, cidr in var.private_subnets_cidr : {
      az   = var.availability_zones[idx % length(var.availability_zones)]
      cidr = cidr
      name = "${var.name_prefix}-private-${var.availability_zones[idx % length(var.availability_zones)]}-${idx + 1}"
    }
  ] : []
  
  nat_gateway_subnets = var.create_private_subnets && var.enable_nat_gateway ? (
    var.single_nat_gateway ? 
    slice(local.public_subnets, 0, 1) :
    slice(local.public_subnets, 0, min(length(local.public_subnets), 2))
  ) : []
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


# Create private subnets
resource "aws_subnet" "private" {
  for_each = var.create_private_subnets ? { for s in local.private_subnets : s.name => s } : {}

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
  for_each = { for s in local.nat_gateway_subnets : s.name => s }
  
  domain = "vpc"
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-eip-nat-${each.value.az}"
    Type = "NAT Gateway EIP"
    AZ   = each.value.az
  })

  depends_on = [aws_subnet.public]
}

# Create NAT Gateways in public subnets
resource "aws_nat_gateway" "private" {
  for_each = { for s in local.nat_gateway_subnets : s.name => s }

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-gateway-${each.value.az}"
    Type = "NAT Gateway"
    AZ   = each.value.az
  })

  depends_on = [aws_eip.nat, aws_route.public_internet]
}

# Create single route table for all private subnets
resource "aws_route_table" "private" {
  count = var.create_private_subnets ? 1 : 0
  
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = var.enable_nat_gateway ? "${var.name_prefix}-rt-private" : "${var.name_prefix}-rt-isolated"
    Type = var.enable_nat_gateway ? "Private with NAT" : "Isolated"
  })
}

# Create single route to NAT Gateway for private subnets
resource "aws_route" "private_nat_gateway" {
  count = var.create_private_subnets && var.enable_nat_gateway ? 1 : 0

  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  
  # Use first NAT Gateway available
  nat_gateway_id = values(aws_nat_gateway.private)[0].id
}

# Associate all private subnets with the private route table
resource "aws_route_table_association" "private" {
  for_each = var.create_private_subnets ? aws_subnet.private : {}

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[0].id
}

# Network ACL for private subnets
resource "aws_network_acl" "private" {
  count  = var.create_private_subnets && var.enable_private_nacl ? 1 : 0
  vpc_id = var.vpc_id
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-nacl"
    Type = "Private NACL"
  })
}

# Inbound rules for specific ports in private NACL
resource "aws_network_acl_rule" "private_inbound_ports" {
  for_each = var.create_private_subnets && var.enable_private_nacl ? toset([for p in var.private_nacl_inbound_ports : tostring(p)]) : []

  network_acl_id = aws_network_acl.private[0].id
  rule_number    = 100 + tonumber(each.value)
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.private_nacl_cidr
  from_port      = tonumber(each.value)
  to_port        = tonumber(each.value)
}

# Inbound rules for ephemeral ports in private NACL
resource "aws_network_acl_rule" "private_inbound_ephemeral" {
  count = var.create_private_subnets && var.enable_private_nacl && var.private_nacl_inbound_ephemeral ? 1 : 0

  network_acl_id = aws_network_acl.private[0].id
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.private_nacl_cidr
  from_port      = 1024
  to_port        = 65535
}

# Outbound rules for specific ports in private NACL
resource "aws_network_acl_rule" "private_outbound_ports" {
  for_each = var.create_private_subnets && var.enable_private_nacl ? toset([for p in var.private_nacl_outbound_ports : tostring(p)]) : []

  network_acl_id = aws_network_acl.private[0].id
  rule_number    = 500 + tonumber(each.value)
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"  # Allow outbound to the internet for updates
  from_port      = tonumber(each.value)
  to_port        = tonumber(each.value)
}

# Outbound rules for ephemeral ports in private NACL
resource "aws_network_acl_rule" "private_outbound_ephemeral" {
  count = var.create_private_subnets && var.enable_private_nacl && var.private_nacl_outbound_ephemeral ? 1 : 0

  network_acl_id = aws_network_acl.private[0].id
  rule_number    = 600
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

# Associate private subnets with private NACL
resource "aws_network_acl_association" "private" {
  for_each = var.create_private_subnets && var.enable_private_nacl ? aws_subnet.private : {}

  subnet_id      = each.value.id
  network_acl_id = aws_network_acl.private[0].id
}