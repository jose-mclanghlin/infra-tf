variable "vpc_id" {
  description = "ID of the VPC where the subnets will be created"
  type        = string
}

variable "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  type        = string
}

variable "availability_zones" {
  description = "List of Availability Zones where the subnets will be created"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "This architecture requires exactly 2 Availability Zones."
  }
}

variable "public_subnets_cidr" {
  description = "List of CIDR blocks for public subnets"
  type = list(object({
    name = optional(string, null)
    cidr = string
  }))
  default = []

  validation {
    condition = (
      length(var.public_subnets_cidr) == 0 ||
      length(var.public_subnets_cidr) % length(var.availability_zones) == 0
    )
    error_message = "The number of PUBLIC subnets must be divisible by the number of Availability Zones (2). Valid examples: 2, 4, 6, ..."
  }
}

variable "private_subnets_cidr" {
  description = "List of CIDR blocks for private subnets"
  type = list(object({
    name = optional(string, null)
    cidr = string
  }))
  default = []

  validation {
    condition = (
      var.create_private_subnets == false ||
      length(var.private_subnets_cidr) % length(var.availability_zones) == 0
    )
    error_message = "When private subnets are enabled, the number of PRIVATE subnets must be divisible by the number of Availability Zones (2). Valid examples: 2, 4, 6, ..."
  }
}

variable "create_private_subnets" {
  description = "Whether to create private subnets"
  type        = bool
  default     = false
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
