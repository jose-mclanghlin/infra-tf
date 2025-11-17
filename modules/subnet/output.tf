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
  description = "IDs of the public route tables (per AZ)"
  value       = values(aws_route_table.public)[*].id
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
  description = "IDs of the private route tables (per AZ)"
  value       = var.create_private_subnets ? values(aws_route_table.private)[*].id : []
}

# Combined outputs
output "all_subnet_ids" {
  description = "All subnet IDs (public and private)"
  value = concat(
    values(aws_subnet.public)[*].id,
    var.create_private_subnets ? values(aws_subnet.private)[*].id : []
  )
}

# NAT Gateway Outputs (conditional based on resource existence)
output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = var.create_private_subnets ? try(values(aws_nat_gateway.nat)[*].id, []) : []
}

output "nat_gateway_public_ips" {
  description = "Public IPs of the NAT Gateways"
  value       = var.create_private_subnets ? try(values(aws_eip.nat)[*].public_ip, []) : []
}

output "elastic_ip_ids" {
  description = "IDs of the Elastic IPs for NAT Gateways"
  value       = var.create_private_subnets ? try(values(aws_eip.nat)[*].id, []) : []
}

output "nat_gateway_azs" {
  description = "Availability zones of the NAT Gateways"
  value       = var.create_private_subnets ? try(distinct([for nat in aws_nat_gateway.nat : nat.subnet_id]), []) : []
}

# Subnet mapping by AZ (very useful for other modules)
output "public_subnets_by_az" {
  description = "Map of availability zones to public subnet IDs"
  value = {
    for az in distinct([for subnet in aws_subnet.public : subnet.availability_zone]) :
    az => [for subnet in aws_subnet.public : subnet.id if subnet.availability_zone == az]
  }
}

output "private_subnets_by_az" {
  description = "Map of availability zones to private subnet IDs"
  value = var.create_private_subnets ? {
    for az in distinct([for subnet in values(aws_subnet.private) : subnet.availability_zone]) :
    az => [for subnet in values(aws_subnet.private) : subnet.id if subnet.availability_zone == az]
  } : {}
}

# Complete subnet information (detailed object)
output "subnet_details" {
  description = "Detailed information about all subnets"
  value = {
    public = {
      for key, subnet in aws_subnet.public : key => {
        id                = subnet.id
        arn               = subnet.arn
        cidr_block        = subnet.cidr_block
        availability_zone = subnet.availability_zone
        vpc_id           = subnet.vpc_id
      }
    }
    private = var.create_private_subnets ? {
      for key, subnet in aws_subnet.private : key => {
        id                = subnet.id
        arn               = subnet.arn
        cidr_block        = subnet.cidr_block
        availability_zone = subnet.availability_zone
        vpc_id           = subnet.vpc_id
      }
    } : {}
  }
}

# Route table ARNs (missing from current outputs)
output "public_route_table_arn" {
  description = "ARNs of the public route tables (per AZ)"
  value       = values(aws_route_table.public)[*].arn
}

output "private_route_table_arn" {
  description = "ARNs of the private route tables (per AZ)"
  value       = var.create_private_subnets ? values(aws_route_table.private)[*].arn : []
}

# Summary counts
output "subnet_summary" {
  description = "Summary of subnet counts by type"
  value = {
    public_count  = length(aws_subnet.public)
    private_count = var.create_private_subnets ? length(aws_subnet.private) : 0
    total_count   = length(aws_subnet.public) + (var.create_private_subnets ? length(aws_subnet.private) : 0)
    azs_used      = distinct(concat(
      [for subnet in aws_subnet.public : subnet.availability_zone],
      var.create_private_subnets ? [for subnet in values(aws_subnet.private) : subnet.availability_zone] : []
    ))
    nat_gateways_count = var.create_private_subnets ? try(length(aws_nat_gateway.nat), 0) : 0
  }
}

# Internet Gateway ID (for reference)
output "internet_gateway_id" {
  description = "ID of the Internet Gateway (passed through)"
  value       = var.internet_gateway_id
}

# VPC ID (for reference)
output "vpc_id" {
  description = "ID of the VPC (passed through)"
  value       = var.vpc_id
}