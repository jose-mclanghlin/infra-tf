# See more: https://medium.com/@sanoj.sudo/how-to-create-aws-vpc-788dc3c4193b

# Create public subnets
resource "aws_subnet" "public" {
  for_each                = { for idx, cidr in var.subnet_config.public_subnets_cidr : idx => cidr }
  vpc_id                  = var.vpc_id
  cidr_block              = each.value
  availability_zone       = var.subnet_config.azs[each.key]
  map_public_ip_on_launch = true
  
  tags = merge(var.tags, {
    Name = "${var.subnet_config.name}-public-${each.key + 1}"
    Type = "Public"
  })
}

# Create private subnets
resource "aws_subnet" "private" {
  for_each                = { for idx, cidr in var.subnet_config.private_subnets_cidr : idx => cidr }
  vpc_id                  = var.vpc_id
  cidr_block              = each.value
  availability_zone       = var.subnet_config.azs[each.key]
  map_public_ip_on_launch = false
  
  tags = merge(var.tags, {
    Name = "${var.subnet_config.name}-private-${each.key + 1}"
    Type = "Private"
  })
}

# This route table directs internet-bound traffic from public subnets to the internet gateway
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id
  
  tags = merge(var.tags, {
    Name = "${var.subnet_config.name}-rt-public"
    Type = "Public"
  })
}

# This route allows outbound internet access from public subnets
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0" # All IPv4 traffic
  gateway_id             = var.internet_gateway_id
}

# Associates the public subnets with the public route table
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Private route table and NAT gateway for private subnets (conditional)
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway && length(var.subnet_config.private_subnets_cidr) > 0 ? 1 : 0
  domain = "vpc"
  
  tags = merge(var.tags, {
    Name = "${var.subnet_config.name}-nat-eip"
  })
}

# This allows outbound internet access for private subnets
resource "aws_nat_gateway" "this" {
  count         = var.enable_nat_gateway && length(var.subnet_config.private_subnets_cidr) > 0 ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = values(aws_subnet.public)[0].id
  
  tags = merge(var.tags, {
    Name = "${var.subnet_config.name}-nat-gw"
  })
  
  depends_on = [var.internet_gateway_id]
}

# Private route table
resource "aws_route_table" "private" {
  count  = length(var.subnet_config.private_subnets_cidr) > 0 ? 1 : 0
  vpc_id = var.vpc_id
  
  tags = merge(var.tags, {
    Name = "${var.subnet_config.name}-private-rt"
    Type = "Private"  
  })
}

# Route for private subnets internet access through NAT Gateway
resource "aws_route" "private_internet_access" {
  count                  = var.enable_nat_gateway && length(var.subnet_config.private_subnets_cidr) > 0 ? 1 : 0
  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
}

# Associates the private subnets with the private route table
resource "aws_route_table_association" "private" {
  for_each       = length(var.subnet_config.private_subnets_cidr) > 0 ? aws_subnet.private : {}
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[0].id
}
