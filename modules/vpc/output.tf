output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.this.id
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.this.arn
}

output "default_security_group_id" {
  description = "ID of the default security group"
  value       = aws_vpc.this.default_security_group_id
}

output "default_route_table_id" {
  description = "ID of the default route table"
  value       = aws_vpc.this.default_route_table_id
}