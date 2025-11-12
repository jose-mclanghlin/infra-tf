# Public Subnet Outputs
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "public_subnet_arns" {
  description = "List of public subnet ARNs"
  value       = [for subnet in aws_subnet.public : subnet.arn]
}

output "public_subnet_cidr_blocks" {
  description = "List of public subnet CIDR blocks"
  value       = [for subnet in aws_subnet.public : subnet.cidr_block]
}

output "public_subnet_availability_zones" {
  description = "List of public subnet availability zones"
  value       = [for subnet in aws_subnet.public : subnet.availability_zone]
}

# Private Subnet Outputs
output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "private_subnet_arns" {
  description = "List of private subnet ARNs"
  value       = [for subnet in aws_subnet.private : subnet.arn]
}

output "private_subnet_cidr_blocks" {
  description = "List of private subnet CIDR blocks"
  value       = [for subnet in aws_subnet.private : subnet.cidr_block]
}

output "private_subnet_availability_zones" {
  description = "List of private subnet availability zones"
  value       = [for subnet in aws_subnet.private : subnet.availability_zone]
}

# All Subnets Combined
output "all_subnet_ids" {
  description = "List of all subnet IDs (public + private)"
  value       = concat([for subnet in aws_subnet.public : subnet.id], [for subnet in aws_subnet.private : subnet.id])
}

# Route Table Outputs
output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = length(aws_route_table.private) > 0 ? aws_route_table.private[0].id : null
}

# NAT Gateway Outputs
output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = length(aws_nat_gateway.this) > 0 ? aws_nat_gateway.this[0].id : null
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway"
  value       = length(aws_nat_gateway.this) > 0 ? aws_nat_gateway.this[0].public_ip : null
}

output "nat_eip_id" {
  description = "ID of the NAT Gateway Elastic IP"
  value       = length(aws_eip.nat) > 0 ? aws_eip.nat[0].id : null
}

output "nat_eip_public_ip" {
  description = "Public IP of the NAT Gateway Elastic IP"
  value       = length(aws_eip.nat) > 0 ? aws_eip.nat[0].public_ip : null
}

# Summary outputs for easy reference
output "subnet_summary" {
  description = "Summary of created subnets"
  value = {
    public_subnets = {
      count = length(aws_subnet.public)
      ids   = [for subnet in aws_subnet.public : subnet.id]
      cidrs = [for subnet in aws_subnet.public : subnet.cidr_block]
    }
    private_subnets = {
      count = length(aws_subnet.private)
      ids   = [for subnet in aws_subnet.private : subnet.id]  
      cidrs = [for subnet in aws_subnet.private : subnet.cidr_block]
    }
    nat_gateway_enabled = var.enable_nat_gateway && length(var.subnet_config.private_subnets_cidr) > 0
  }
}
