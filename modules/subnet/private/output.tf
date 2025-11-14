# Private Subnet Outputs
output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = values(aws_subnet.private)[*].id
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of the private subnets"
  value       = values(aws_subnet.private)[*].cidr_block
}

output "private_subnet_azs" {
  description = "Availability zones of the private subnets"
  value       = values(aws_subnet.private)[*].availability_zone
}

output "private_route_table_ids" {
  description = "IDs of the private route tables"
  value       = values(aws_route_table.private)[*].id
}

# NAT Gateway Outputs
output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = var.enable_nat_gateway ? aws_nat_gateway.private[*].id : []
}

output "nat_gateway_public_ips" {
  description = "Public IPs of the NAT Gateways"
  value       = var.enable_nat_gateway ? aws_eip.nat[*].public_ip : []
}

output "elastic_ip_ids" {
  description = "IDs of the Elastic IPs for NAT Gateways"
  value       = var.enable_nat_gateway ? aws_eip.nat[*].id : []
}

# Network ACL Outputs
output "private_nacl_id" {
  description = "ID of the private Network ACL"
  value       = var.enable_nacl ? aws_network_acl.private[0].id : null
}

# Subnet information by AZ
output "private_subnets_by_az" {
  description = "Map of availability zones to private subnet IDs"
  value = {
    for subnet in values(aws_subnet.private) : subnet.availability_zone => subnet.id
  }
}

# Combined information
output "subnet_info" {
  description = "Detailed information about private subnets"
  value = [
    for subnet in values(aws_subnet.private) : {
      id                = subnet.id
      cidr_block        = subnet.cidr_block
      availability_zone = subnet.availability_zone
      arn              = subnet.arn
    }
  ]
}
