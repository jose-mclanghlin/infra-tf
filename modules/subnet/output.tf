# Outputs de subnets públicas
output "public_subnet_ids" {
  description = "Lista de IDs de subnets públicas"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "public_subnet_arns" {
  description = "Lista de ARNs de subnets públicas"
  value       = [for subnet in aws_subnet.public : subnet.arn]
}

output "public_subnet_cidr_blocks" {
  description = "Lista de CIDR blocks de subnets públicas"
  value       = [for subnet in aws_subnet.public : subnet.cidr_block]
}

output "public_subnet_availability_zones" {
  description = "Lista de availability zones de subnets públicas"
  value       = [for subnet in aws_subnet.public : subnet.availability_zone]
}

output "public_route_table_id" {
  description = "ID de la route table pública"
  value       = aws_route_table.public.id
}

output "subnet_count" {
  description = "Número de subnets públicas creadas"
  value       = length(aws_subnet.public)
}
