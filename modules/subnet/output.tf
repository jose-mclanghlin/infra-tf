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

# Private Subnet Outputs
output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = var.create_private_subnets ? values(aws_subnet.private)[*].id : []
}

output "private_subnet_arns" {
  description = "ARNs of the private subnets"
  value       = var.create_private_subnets ? values(aws_subnet.private)[*].arn : []
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of the private subnets"
  value       = var.create_private_subnets ? values(aws_subnet.private)[*].cidr_block : []
}

output "private_subnet_azs" {
  description = "Availability zones of the private subnets"
  value       = var.create_private_subnets ? values(aws_subnet.private)[*].availability_zone : []
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = var.create_private_subnets ? aws_route_table.private.id : null
}

# Combined outputs
output "all_subnet_ids" {
  description = "All subnet IDs (public and private)"
  value = concat(
    values(aws_subnet.public)[*].id,
    var.create_private_subnets ? values(aws_subnet.private)[*].id : []
  )
}