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

# EC2 Outputs
output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2.public_ip
}

output "ec2_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = module.ec2.private_ip
}

output "ec2_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = module.ec2.public_dns
}

output "ec2_security_group_id" {
  description = "ID of the security group"
  value       = module.ec2.security_group_id
}

output "ec2_elastic_ip" {
  description = "Elastic IP address (if created)"
  value       = module.ec2.elastic_ip
}