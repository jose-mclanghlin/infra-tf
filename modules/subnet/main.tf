# Public Subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnets)
  
  vpc_id                  = var.vpc_id
  cidr_block              = var.public_subnets[count.index].cidr_block
  availability_zone       = var.public_subnets[count.index].availability_zone
  map_public_ip_on_launch = var.public_subnets[count.index].map_public_ip_on_launch
  
  tags = merge(var.tags, var.public_subnets[count.index].tags, {
    Name = var.public_subnets[count.index].name != "" ? var.public_subnets[count.index].name : "${var.name_prefix}-public-${count.index + 1}"
    Type = "Public"
  })
}

# Private Subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnets)
  
  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnets[count.index].cidr_block
  availability_zone = var.private_subnets[count.index].availability_zone
  
  tags = merge(var.tags, var.private_subnets[count.index].tags, {
    Name = var.private_subnets[count.index].name != "" ? var.private_subnets[count.index].name : "${var.name_prefix}-private-${count.index + 1}"
    Type = "Private"
  })
}

# Database Subnets (optional)
resource "aws_subnet" "database" {
  count = length(var.database_subnets)
  
  vpc_id            = var.vpc_id
  cidr_block        = var.database_subnets[count.index].cidr_block
  availability_zone = var.database_subnets[count.index].availability_zone
  
  tags = merge(var.tags, var.database_subnets[count.index].tags, {
    Name = var.database_subnets[count.index].name != "" ? var.database_subnets[count.index].name : "${var.name_prefix}-db-${count.index + 1}"
    Type = "Database"
  })
}

# Public Route Table
resource "aws_route_table" "public" {
  count = var.create_public_route_table && length(var.public_subnets) > 0 ? 1 : 0
  
  vpc_id = var.vpc_id
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-rt"
    Type = "Public"
  })
}

# Public Route to Internet Gateway
resource "aws_route" "public_internet_gateway" {
  count = var.create_public_route_table && var.internet_gateway_id != "" && length(var.public_subnets) > 0 ? 1 : 0
  
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.internet_gateway_id
}

# Public Route Table Associations
resource "aws_route_table_association" "public" {
  count = var.create_public_route_table && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0
  
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  count = var.create_nat_gateway && length(var.private_subnets) > 0 ? var.single_nat_gateway ? 1 : length(var.public_subnets) : 0
  
  domain = "vpc"
  
  tags = merge(var.tags, {
    Name = var.single_nat_gateway ? "${var.name_prefix}-nat-eip" : "${var.name_prefix}-nat-eip-${count.index + 1}"
  })
  
  depends_on = [var.internet_gateway_id]
}

# NAT Gateway
resource "aws_nat_gateway" "this" {
  count = var.create_nat_gateway && length(var.private_subnets) > 0 ? var.single_nat_gateway ? 1 : length(var.public_subnets) : 0
  
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[var.single_nat_gateway ? 0 : count.index].id
  
  tags = merge(var.tags, {
    Name = var.single_nat_gateway ? "${var.name_prefix}-nat-gw" : "${var.name_prefix}-nat-gw-${count.index + 1}"
  })
  
  depends_on = [var.internet_gateway_id]
}

# Private Route Tables
resource "aws_route_table" "private" {
  count = var.create_private_route_table && length(var.private_subnets) > 0 ? var.single_nat_gateway ? 1 : length(var.private_subnets) : 0
  
  vpc_id = var.vpc_id
  
  tags = merge(var.tags, {
    Name = var.single_nat_gateway ? "${var.name_prefix}-private-rt" : "${var.name_prefix}-private-rt-${count.index + 1}"
    Type = "Private"
  })
}

# Private Routes to NAT Gateway
resource "aws_route" "private_nat_gateway" {
  count = var.create_nat_gateway && var.create_private_route_table && length(var.private_subnets) > 0 ? var.single_nat_gateway ? 1 : length(var.private_subnets) : 0
  
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[var.single_nat_gateway ? 0 : count.index].id
}

# Private Route Table Associations
resource "aws_route_table_association" "private" {
  count = var.create_private_route_table && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0
  
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[var.single_nat_gateway ? 0 : count.index].id
}

# Database Route Table
resource "aws_route_table" "database" {
  count = var.create_database_route_table && length(var.database_subnets) > 0 ? 1 : 0
  
  vpc_id = var.vpc_id
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-database-rt"
    Type = "Database"
  })
}

# Database Route Table Associations
resource "aws_route_table_association" "database" {
  count = var.create_database_route_table && length(var.database_subnets) > 0 ? length(var.database_subnets) : 0
  
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database[0].id
}

# Database Subnet Group
resource "aws_db_subnet_group" "database" {
  count = var.create_database_subnet_group && length(var.database_subnets) > 0 ? 1 : 0
  
  name       = var.database_subnet_group_name != "" ? var.database_subnet_group_name : "${var.name_prefix}-db-subnet-group"
  subnet_ids = aws_subnet.database[*].id
  
  tags = merge(var.tags, {
    Name = var.database_subnet_group_name != "" ? var.database_subnet_group_name : "${var.name_prefix}-db-subnet-group"
  })
}