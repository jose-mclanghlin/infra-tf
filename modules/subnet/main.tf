# Crear subnets publicas (todas en la misma zona)
resource "aws_subnet" "public" {
  for_each = { for idx, cidr in var.public_subnets_cidr : idx => cidr }
  
  vpc_id                  = var.vpc_id
  cidr_block              = each.value
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-${each.key + 1}"
    Type = "Public"
  })
}

# Route table para subnets publicas
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-rt"
    Type = "Public"
  })
}

# Ruta hacia Internet Gateway
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.internet_gateway_id
}

# Asociar subnets publicas con route table
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public
  
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}
