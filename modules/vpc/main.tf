// See more: https://medium.com/@sanoj.sudo/how-to-create-aws-vpc-788dc3c4193b
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.name
  }
}

# This allows communication between the VPC and the internet
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_subnet" "public" {
  for_each                = { for idx, cidr in var.public_subnets_cidr : idx => cidr } // Iterate over public subnet CIDRs
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = var.azs[each.key]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name}-public-${each.key + 1}"
  }
}

resource "aws_subnet" "private" {
  for_each          = { for idx, cidr in var.private_subnets_cidr : idx => cidr }
  vpc_id            = aws_vpc.this.id              
  cidr_block        = each.value
  availability_zone = var.azs[each.key]
  map_public_ip_on_launch = false 
  tags = {
    Name = "${var.name}-private-${each.key + 1}"
  }
}

# This route table directs internet-bound traffic from public subnets to the internet gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.name}-rt-public"
  }
}

# This route allows outbound internet access from public subnets
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0" # All IPv4 traffic
  gateway_id             = aws_internet_gateway.this.id
}

# Associates the public subnets with the public route table
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Private route table and NAT gateway for private subnets
resource "aws_eip" "nat" {
  tags = {
    Name = "${var.name}-nat-eip"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = values(aws_subnet.public)[0].id
  tags = {
    Name = "${var.name}-nat-gw"
  }
  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.name}-private-rt"
  }
}

resource "aws_route" "private_internet_access" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}