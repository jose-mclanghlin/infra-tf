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

# Network ACL para subnets públicas
resource "aws_network_acl" "public" {
  count  = var.enable_nacl ? 1 : 0
  vpc_id = var.vpc_id
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-nacl"
    Type = "Public"
  })
}

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

# Create route tables for private subnets
resource "aws_route_table" "private" {
  for_each = var.create_private_subnets ? aws_subnet.private : {}

  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = var.enable_nat_gateway ? "${var.name_prefix}-rt-private-${replace(each.key, "${var.name_prefix}-private-", "")}" : "${var.name_prefix}-rt-isolated-${replace(each.key, "${var.name_prefix}-private-", "")}"
    Type = var.enable_nat_gateway ? "Private with NAT" : "Isolated"
  })
}

# Create routes to NAT Gateway (if enabled)
resource "aws_route" "private_nat_gateway" {
  for_each = var.create_private_subnets && var.enable_nat_gateway ? aws_route_table.private : {}

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  
  # Select NAT Gateway based on strategy
  nat_gateway_id = var.single_nat_gateway ? (
    # Single NAT Gateway: use the only one available
    values(aws_nat_gateway.private)[0].id
  ) : (
    # Multiple NAT Gateways: distribute by AZ
    # Extract AZ from private subnet key and find matching NAT Gateway
    try(
      [for nat_key, nat in aws_nat_gateway.private : 
        nat.id if contains(each.key, regex("(us-[a-z]+-[0-9][a-z])", nat_key))
      ][0],
      values(aws_nat_gateway.private)[0].id  # fallback to first NAT Gateway
    )
  )
}

# Associate private subnets with route tables
resource "aws_route_table_association" "private" {
  for_each = var.create_private_subnets ? aws_subnet.private : {}

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
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

resource "aws_network_acl_rule" "private_outbound_ports" {
  for_each = var.create_private_subnets && var.enable_private_nacl ? toset([for p in var.private_nacl_outbound_ports : tostring(p)]) : []

  network_acl_id = aws_network_acl.private[0].id
  rule_number    = 500 + tonumber(each.value)
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"  # Allow outbound to internet for updates
  from_port      = tonumber(each.value)
  to_port        = tonumber(each.value)
}

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

resource "aws_network_acl_association" "private" {
  for_each = var.create_private_subnets && var.enable_private_nacl ? aws_subnet.private : {}

  subnet_id      = each.value.id
  network_acl_id = aws_network_acl.private[0].id
}