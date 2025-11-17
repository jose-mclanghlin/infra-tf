locals {
  # Process public subnets with custom names support
  public_subnets = [
    for idx, subnet in var.public_subnets_cidr : {
      az   = var.availability_zones[idx % length(var.availability_zones)]  # round-robin assignment of AZs
      cidr = subnet.cidr
      name = subnet.name != null ? subnet.name : "${var.name_prefix}-public-${var.availability_zones[idx % length(var.availability_zones)]}-${idx + 1}"
    }
  ]
  
  # Process private subnets with custom names support
  private_subnets = var.create_private_subnets ? [
    for idx, subnet in var.private_subnets_cidr : {
      az   = var.availability_zones[idx % length(var.availability_zones)]  # round-robin assignment of AZs
      cidr = subnet.cidr
      name = subnet.name != null ? subnet.name : "${var.name_prefix}-private-${var.availability_zones[idx % length(var.availability_zones)]}-${idx + 1}"
    }
  ] : []
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

# Create route table for private subnets
resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-rt-private"
    Type = "Private"
  })
}

# Associate all private subnets with the private route table
resource "aws_route_table_association" "private" {
  for_each = var.create_private_subnets ? aws_subnet.private : {}

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}