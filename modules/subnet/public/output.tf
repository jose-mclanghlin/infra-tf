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

# Network ACL Outputs
output "network_acl_id" {
  description = "ID del Network ACL público"
  value       = var.enable_nacl && length(aws_network_acl.public) > 0 ? aws_network_acl.public[0].id : null
}

output "network_acl_arn" {
  description = "ARN del Network ACL público"
  value       = var.enable_nacl && length(aws_network_acl.public) > 0 ? aws_network_acl.public[0].arn : null
}

output "network_acl_enabled" {
  description = "Indica si el Network ACL está habilitado"
  value       = var.enable_nacl
}

output "nacl_allowed_inbound_ports" {
  description = "Puertos de entrada permitidos en el NACL"
  value       = var.public_nacl_inbound_ports
}

output "nacl_allowed_outbound_ports" {
  description = "Puertos de salida permitidos en el NACL"
  value       = var.public_nacl_outbound_ports
}
