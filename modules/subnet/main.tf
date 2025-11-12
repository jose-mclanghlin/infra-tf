# Data sources para obtener información de availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Locals para organizar subnets por tipo
locals {
  public_subnets = {
    for k, v in var.subnets : k => v if v.public
  }
  
  private_subnets = {
    for k, v in var.subnets : k => v if !v.public
  }
  
  # Para NAT Gateway, usar solo la primera subnet pública si single_nat_gateway es true
  nat_gateway_subnets = var.single_nat_gateway ? {
    for k, v in local.public_subnets : k => v if k == keys(local.public_subnets)[0]
  } : local.public_subnets
}

# Crear todas las subnets
resource "aws_subnet" "this" {
  for_each = var.subnets
  
  vpc_id                  = var.vpc_id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.public
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}${each.key}"
    Type = each.value.public ? "Public" : "Private"
  })
}

# Elastic IPs para NAT Gateways
resource "aws_eip" "nat" {
  for_each = var.enable_nat_gateway ? local.nat_gateway_subnets : {}
  
  domain = "vpc"
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}nat-${each.key}-eip"
  })
  
  depends_on = [var.internet_gateway_id]
}

# NAT Gateways
resource "aws_nat_gateway" "this" {
  for_each = var.enable_nat_gateway ? local.nat_gateway_subnets : {}
  
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.this[each.key].id
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}nat-${each.key}"
  })
  
  depends_on = [var.internet_gateway_id]
}

# Route Table para subnets públicas
resource "aws_route_table" "public" {
  count = length(local.public_subnets) > 0 ? 1 : 0
  
  vpc_id = var.vpc_id
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}public-rt"
    Type = "Public"
  })
}

# Ruta hacia Internet Gateway para subnets públicas
resource "aws_route" "public_internet" {
  count = length(local.public_subnets) > 0 && var.internet_gateway_id != null ? 1 : 0
  
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.internet_gateway_id
}

# Asociar subnets públicas con route table pública
resource "aws_route_table_association" "public" {
  for_each = local.public_subnets
  
  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.public[0].id
}

# Route Tables para subnets privadas
resource "aws_route_table" "private" {
  for_each = var.enable_nat_gateway ? local.private_subnets : {}
  
  vpc_id = var.vpc_id
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}private-${each.key}-rt"
    Type = "Private"
  })
}

# Rutas hacia NAT Gateway para subnets privadas
resource "aws_route" "private_nat" {
  for_each = var.enable_nat_gateway ? local.private_subnets : {}
  
  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.this[keys(local.nat_gateway_subnets)[0]].id : aws_nat_gateway.this[each.key].id
}

# Asociar subnets privadas con sus route tables
resource "aws_route_table_association" "private" {
  for_each = var.enable_nat_gateway ? local.private_subnets : {}
  
  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}
