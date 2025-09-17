# ID de la VPC creada
output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.this.id
}

# IDs de las subnets públicas
output "public_subnet_ids" {
  description = "IDs de las subnets públicas"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

# IDs de las subnets privadas
output "private_subnet_ids" {
  description = "IDs de las subnets privadas"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

# ID del Internet Gateway
output "internet_gateway_id" {
  description = "ID del Internet Gateway"
  value       = aws_internet_gateway.this.id
}