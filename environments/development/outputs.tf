output "vpc_id" {
  description = "The ID of the created VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets created within the VPC."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets created within the VPC."
  value       = module.vpc.private_subnet_ids
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway attached to the VPC."
  value       = module.vpc.internet_gateway_id
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway created for the VPC."
  value       = module.vpc.nat_gateway_id
}

output "nat_eip" {
  description = "The Elastic IP address associated with the NAT Gateway."
  value       = module.vpc.nat_eip
}

output "private_route_table_id" {
  description = "The ID of the route table associated with private subnets."
  value       = module.vpc.private_route_table_id
}