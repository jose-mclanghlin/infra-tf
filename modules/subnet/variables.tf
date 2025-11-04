variable "vpc_config" {
  description = "Complete VPC configuration object"
  type = object({
    cidr_block            = string
    name                  = string
    public_subnets_cidr   = list(string)
    private_subnets_cidr  = list(string)
    azs                   = list(string)
  })

  validation {
    condition     = can(cidrhost(var.vpc_config.cidr_block, 0))
    error_message = "VPC CIDR must be valid (e.g., 10.0.0.0/16)."
  }

  validation {
    condition     = alltrue([for cidr in var.vpc_config.public_subnets_cidr : can(cidrhost(cidr, 0))])
    error_message = "All public subnet CIDRs must be valid."
  }

  validation {
    condition     = alltrue([for cidr in var.vpc_config.private_subnets_cidr : can(cidrhost(cidr, 0))])
    error_message = "All private subnet CIDRs must be valid."
  }

  validation {
    condition     = length(var.vpc_config.azs) >= 1
    error_message = "Must specify at least 1 availability zone."
  }

  validation {
    condition     = length(var.vpc_config.public_subnets_cidr) == length(var.vpc_config.azs)
    error_message = "Number of public subnets must match number of availability zones."
  }

  validation {
    condition     = length(var.vpc_config.private_subnets_cidr) == length(var.vpc_config.azs)
    error_message = "Number of private subnets must match number of availability zones."
  }
}