# VPC ID
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

# Public subnet IDs
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

# Private subnet IDs
output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

# Internet Gateway ID
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.this.id
}

# NAT Gateway ID
output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.this.id
}

# NAT Gateway's Elastic IP
output "nat_eip" {
  description = "Public Elastic IP associated with the NAT Gateway"
  value       = aws_eip.nat.public_ip
}

# Private route table ID
output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.private.id
}