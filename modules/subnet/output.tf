# Outputs de todas las subnets
output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value = {
    for k, v in aws_subnet.this : k => v.id
  }
}

output "subnet_arns" {
  description = "Map of subnet names to their ARNs"
  value = {
    for k, v in aws_subnet.this : k => v.arn
  }
}

output "subnet_cidr_blocks" {
  description = "Map of subnet names to their CIDR blocks"
  value = {
    for k, v in aws_subnet.this : k => v.cidr_block
  }
}

output "subnet_availability_zones" {
  description = "Map of subnet names to their availability zones"
  value = {
    for k, v in aws_subnet.this : k => v.availability_zone
  }
}

# Outputs específicos para subnets públicas
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value = [
    for k, v in aws_subnet.this : v.id if lookup(var.subnets[k], "public", false)
  ]
}

output "public_subnet_cidr_blocks" {
  description = "List of public subnet CIDR blocks"
  value = [
    for k, v in aws_subnet.this : v.cidr_block if lookup(var.subnets[k], "public", false)
  ]
}

# Outputs específicos para subnets privadas
output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value = [
    for k, v in aws_subnet.this : v.id if !lookup(var.subnets[k], "public", false)
  ]
}

output "private_subnet_cidr_blocks" {
  description = "List of private subnet CIDR blocks"
  value = [
    for k, v in aws_subnet.this : v.cidr_block if !lookup(var.subnets[k], "public", false)
  ]
}

# Outputs de NAT Gateways
output "nat_gateway_ids" {
  description = "Map of NAT Gateway names to their IDs"
  value = {
    for k, v in aws_nat_gateway.this : k => v.id
  }
}

output "nat_gateway_public_ips" {
  description = "Map of NAT Gateway names to their public IPs"
  value = {
    for k, v in aws_nat_gateway.this : k => v.public_ip
  }
}

# Outputs de Route Tables
output "public_route_table_id" {
  description = "ID of the public route table"
  value = length(aws_route_table.public) > 0 ? aws_route_table.public[0].id : null
}

output "private_route_table_ids" {
  description = "Map of private route table names to their IDs"
  value = {
    for k, v in aws_route_table.private : k => v.id
  }
}

# Outputs de Elastic IPs
output "nat_eip_ids" {
  description = "Map of NAT Gateway EIP names to their IDs"
  value = {
    for k, v in aws_eip.nat : k => v.id
  }
}

output "nat_eip_public_ips" {
  description = "Map of NAT Gateway EIP names to their public IPs"
  value = {
    for k, v in aws_eip.nat : k => v.public_ip
  }
}
