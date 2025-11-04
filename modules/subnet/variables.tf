variable "vpc_id" {
  description = "ID of the VPC where subnets will be created"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet configurations"
  type = list(object({
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = optional(bool, true)
    name                    = optional(string, "")
    tags                    = optional(map(string), {})
  }))
  default = []
  
  validation {
    condition = alltrue([
      for subnet in var.public_subnets : can(cidrhost(subnet.cidr_block, 0))
    ])
    error_message = "All public subnet CIDRs must be valid."
  }
}

variable "private_subnets" {
  description = "List of private subnet configurations"
  type = list(object({
    cidr_block        = string
    availability_zone = string
    name              = optional(string, "")
    tags              = optional(map(string), {})
  }))
  default = []
  
  validation {
    condition = alltrue([
      for subnet in var.private_subnets : can(cidrhost(subnet.cidr_block, 0))
    ])
    error_message = "All private subnet CIDRs must be valid."
  }
}

variable "database_subnets" {
  description = "List of database subnet configurations"
  type = list(object({
    cidr_block        = string
    availability_zone = string
    name              = optional(string, "")
    tags              = optional(map(string), {})
  }))
  default = []
  
  validation {
    condition = alltrue([
      for subnet in var.database_subnets : can(cidrhost(subnet.cidr_block, 0))
    ])
    error_message = "All database subnet CIDRs must be valid."
  }
}

variable "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  type        = string
  default     = ""
}

variable "create_public_route_table" {
  description = "Whether to create public route table"
  type        = bool
  default     = true
}

variable "create_private_route_table" {
  description = "Whether to create private route table(s)"
  type        = bool
  default     = true
}

variable "create_database_route_table" {
  description = "Whether to create database route table"
  type        = bool
  default     = true
}

variable "create_nat_gateway" {
  description = "Whether to create NAT Gateway(s)"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Whether to use a single NAT Gateway for all private subnets"
  type        = bool
  default     = false
}

variable "create_database_subnet_group" {
  description = "Whether to create database subnet group"
  type        = bool
  default     = true
}

variable "database_subnet_group_name" {
  description = "Name for the database subnet group"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}