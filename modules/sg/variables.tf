variable "name" {
  description = "Name of the security group"
  type        = string
  
  validation {
    condition     = length(var.name) > 0
    error_message = "The security group name must not be empty."
  }
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.name))
    error_message = "The security group name may only contain letters, numbers, hyphens, and underscores."
  }
}

variable "description" {
  description = "Description of the security group"
  type        = string
  default     = "Managed by Terraform"

  validation {
    condition     = length(var.description) > 0
    error_message = "The security group description must not be empty."
  }

  validation {
    condition     = length(var.description) <= 255
    error_message = "The security group description must not exceed 255 characters."
  }
}

variable "vpc_id" {
  description = "VPC where the security group will be created"
  type        = string
  
  validation {
    condition     = length(var.vpc_id) > 0
    error_message = "The VPC ID must not be empty."
  }

  validation {
    condition     = can(regex("^vpc-[0-9a-fA-F]{8,17}$", var.vpc_id))
    error_message = "The VPC ID must start with 'vpc-' followed by 8 to 17 hexadecimal characters."
  }
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string))
    security_groups = optional(list(string))
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress rules"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string))
    security_groups = optional(list(string))
  }))
  default = []
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}