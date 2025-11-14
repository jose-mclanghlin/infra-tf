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

# ===== PRIVATE SUBNET OUTPUTS =====

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

output "private_route_table_ids" {
  description = "IDs of the private route tables"
  value       = var.create_private_subnets ? values(aws_route_table.private)[*].id : []
}

# NAT Gateway Outputs
output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = var.create_private_subnets && var.enable_nat_gateway ? values(aws_nat_gateway.private)[*].id : []
}

output "nat_gateway_public_ips" {
  description = "Public IPs of the NAT Gateways"
  value       = var.create_private_subnets && var.enable_nat_gateway ? values(aws_eip.nat)[*].public_ip : []
}

output "elastic_ip_ids" {
  description = "IDs of the Elastic IPs for NAT Gateways"
  value       = var.create_private_subnets && var.enable_nat_gateway ? values(aws_eip.nat)[*].id : []
}

# Private Network ACL Outputs
output "private_network_acl_id" {
  description = "ID of the private Network ACL"
  value       = var.create_private_subnets && var.enable_private_nacl && length(aws_network_acl.private) > 0 ? aws_network_acl.private[0].id : null
}

output "private_nacl_enabled" {
  description = "Indicates whether the private Network ACL is enabled"
  value       = var.create_private_subnets && var.enable_private_nacl
}

# Subnet information by AZ
output "private_subnets_by_az" {
  description = "Map of availability zones to private subnet IDs"
  value = var.create_private_subnets ? {
    for subnet in values(aws_subnet.private) : subnet.availability_zone => subnet.id
  } : {}
}

# Combined subnet information
output "all_subnet_ids" {
  description = "All subnet IDs (public and private)"
  value = concat(
    values(aws_subnet.public)[*].id,
    var.create_private_subnets ? values(aws_subnet.private)[*].id : []
  )
}

output "subnet_info" {
  description = "Detailed information about all subnets"
  value = {
    public = [
      for subnet in values(aws_subnet.public) : {
        id                = subnet.id
        cidr_block        = subnet.cidr_block
        availability_zone = subnet.availability_zone
        type              = "public"
        arn               = subnet.arn
      }
    ]
    private = var.create_private_subnets ? [
      for subnet in values(aws_subnet.private) : {
        id                = subnet.id
        cidr_block        = subnet.cidr_block
        availability_zone = subnet.availability_zone
        type              = "private"
        arn               = subnet.arn
      }
    ] : []
  }
}