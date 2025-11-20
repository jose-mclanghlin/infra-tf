variable "name" {
  description = "Name for the VPC"
  type        = string

  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 50
    error_message = "The VPC name must be between 1 and 50 characters."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.name))
    error_message = "The VPC name may only contain letters, numbers, hyphens, and underscores."
  }
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  
  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "VPC CIDR must be a valid CIDR (e.g., 10.0.0.0/16)."
  }

  validation {
    condition     = tonumber(split("/", var.cidr_block)[1]) <= 28
    error_message = "CIDR prefix must not be larger than /28 for a VPC."
  }

  validation {
    condition     = tonumber(split("/", var.cidr_block)[1]) >= 16
    error_message = "CIDR prefix should be at least /16 for recommended VPC size."
  }
}


variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool

  validation {
    condition     = var.enable_dns_support == true || var.enable_dns_support == false
    error_message = "enable_dns_support must be true or false."
  }

  default = true
}


variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool

  validation {
    condition     = var.enable_dns_hostnames == true || var.enable_dns_hostnames == false
    error_message = "enable_dns_hostnames must be true or false."
  }

  default = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for key, value in var.tags : can(regex("^[a-zA-Z0-9-_]+$", key))])
    error_message = "All tag keys must contain only letters, numbers, hyphens, or underscores."
  }

  validation {
    condition     = alltrue([for key, value in var.tags : length(value) > 0])
    error_message = "All tag values must be non-empty strings."
  }
}
