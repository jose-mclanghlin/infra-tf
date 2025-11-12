# Required Variables
variable "vpc_id" {
  description = "ID of the VPC where subnets will be created"
  type        = string
}

variable "internet_gateway_id" {
  description = "ID of the Internet Gateway for public subnets"
  type        = string
}

variable "subnet_config" {
  description = "Configuration for subnet creation"
  type = object({
    name                   = string
    public_subnets_cidr   = list(string)
    private_subnets_cidr  = list(string)
    azs                   = list(string)
  })
  
  validation {
    condition = length(var.subnet_config.public_subnets_cidr) <= length(var.subnet_config.azs)
    error_message = "Number of public subnets cannot exceed number of availability zones."
  }
  
  validation {
    condition = length(var.subnet_config.private_subnets_cidr) <= length(var.subnet_config.azs)
    error_message = "Number of private subnets cannot exceed number of availability zones."
  }
}

# Optional Variables
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
