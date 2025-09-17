variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "name" {
  description = "Name of the VPC"
  type        = string
}

variable "public_subnets_cidr" {
  description = "List of CIDR blocks for the public subnets"
  type        = list(string)
}

variable "private_subnets_cidr" {
  description = "List of CIDR blocks for the private subnets"
  type        = list(string)
}

variable "azs" {
  description = "List of availability zones (AZs)"
  type        = list(string)
}