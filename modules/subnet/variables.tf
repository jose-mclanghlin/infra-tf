# Basic variables for public subnets
variable "vpc_id" {
  description = "ID of the VPC where the subnets will be created"
  type        = string
}

variable "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  type        = string
}

variable "public_subnets_cidr" {
  description = "List of CIDR blocks for public subnets. Can be strings or objects with 'name' and 'cidr' keys"
  type = list(object({
    name = optional(string, null)
    cidr = string
  }))
  default = []
}

variable "private_subnets_cidr" {
  description = "List of CIDR blocks for private subnets. Can be strings or objects with 'name' and 'cidr' keys"
  type = list(object({
    name = optional(string, null)
    cidr = string
  }))
  default = []
}

variable "create_private_subnets" {
  description = "Whether to create private subnets"
  type        = bool
  default     = false
}

variable "availability_zones" {
  description = "List of Availability Zones where public subnets will be created"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "name_prefix" {
  description = "Prefix used for naming resources"
  type        = string
  default     = "public"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
