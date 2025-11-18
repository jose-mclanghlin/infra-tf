locals {
  public_subnets = [
    for idx, subnet in var.public_subnets_cidr : {
      az   = var.availability_zones[idx % length(var.availability_zones)]  # Round-robin AZ assignment
      cidr = subnet.cidr
      name = subnet.name != null ? subnet.name : "${var.name_prefix}-public-${var.availability_zones[idx % length(var.availability_zones)]}-${idx + 1}"
    }
  ]

  private_subnets = [
    for idx, subnet in var.private_subnets_cidr : {
      az   = var.availability_zones[idx % length(var.availability_zones)]  # Round-robin AZ assignment
      cidr = subnet.cidr
      name = subnet.name != null ? subnet.name : "${var.name_prefix}-private-${var.availability_zones[idx % length(var.availability_zones)]}-${idx + 1}"
    }
  ]

  availability_zones_with_public_subnets = distinct([for s in aws_subnet.public : s.availability_zone])
}

# Public subnets
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
  for_each = { for az in local.availability_zones_with_public_subnets : az => az }
  
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-rt-public-${each.key}"
    Type = "Public"
    AZ   = each.key
  })
  
  depends_on = [aws_subnet.public]
}

resource "aws_route" "public_internet" {
  for_each = aws_route_table.public
  
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.internet_gateway_id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public
  
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public[each.value.availability_zone].id
}


# Private subnets
resource "aws_subnet" "private" {
  for_each = { for s in local.private_subnets : s.name => s }

  vpc_id                  = var.vpc_id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = each.value.name
    Type = "Private"
    AZ   = each.value.az
  })
}

# Route tables for private subnets
resource "aws_route_table" "private" {
  for_each = { for az in distinct([for s in aws_subnet.private : s.availability_zone]) : az => az }
  
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-rt-private-${each.key}"
    Type = "Private"
    AZ   = each.key
  })
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private
  
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.value.availability_zone].id
}

# Elastic IPs for NAT Gateways (one per AZ)
resource "aws_eip" "nat" {
  for_each = { for az in local.availability_zones_with_public_subnets : az => az }
  
  tags = {
    Name = "EIP-NAT-${each.key}"
  }
  depends_on = [aws_subnet.public]
}

# NAT Gateways (one per AZ)
resource "aws_nat_gateway" "nat" {
  for_each = { for az in local.availability_zones_with_public_subnets : az => az }
  
  allocation_id = aws_eip.nat[each.key].id // Associate corresponding EIP
  subnet_id = element([for s in aws_subnet.public : s.id if s.availability_zone == each.key], 0)

  tags = {
    Name = "NAT-GW-${each.key}"
  }
}

# Routes for private subnets to use NAT Gateways (one route per AZ table)
resource "aws_route" "private_nat" {
  for_each = aws_nat_gateway.nat

  route_table_id         = aws_route_table.private[each.key].id  # AZ-specific route table
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = each.value.id  # NAT Gateway from same AZ
}
