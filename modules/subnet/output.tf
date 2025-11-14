# Outputs for public subnets
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "public_subnet_arns" {
  description = "List of public subnet ARNs"
  value       = [for subnet in aws_subnet.public : subnet.arn]
}

output "public_subnet_cidr_blocks" {
  description = "List of CIDR blocks for public subnets"
  value       = [for subnet in aws_subnet.public : subnet.cidr_block]
}

output "public_subnet_availability_zones" {
  description = "List of Availability Zones of public subnets"
  value       = [for subnet in aws_subnet.public : subnet.availability_zone]
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "subnet_count" {
  description = "Number of public subnets created"
  value       = length(aws_subnet.public)
}

# Network ACL Outputs
output "network_acl_id" {
  description = "ID of the public Network ACL"
  value       = var.enable_nacl && length(aws_network_acl.public) > 0 ? aws_network_acl.public[0].id : null
}

output "network_acl_arn" {
  description = "ARN of the public Network ACL"
  value       = var.enable_nacl && length(aws_network_acl.public) > 0 ? aws_network_acl.public[0].arn : null
}

output "network_acl_enabled" {
  description = "Indicates whether the Network ACL is enabled"
  value       = var.enable_nacl
}

output "nacl_allowed_inbound_ports" {
  description = "Inbound ports allowed in the Network ACL"
  value       = var.public_nacl_inbound_ports
}

output "nacl_allowed_outbound_ports" {
  description = "Outbound ports allowed in the Network ACL"
  value       = var.public_nacl_outbound_ports
}