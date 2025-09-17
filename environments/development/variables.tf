variable "vpc_cidr" {
  type        = string
  description = "CIDR principal de la VPC"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "El CIDR de la VPC debe ser válido (ej: 10.0.0.0/16)."
  }
}

variable "public_subnets_cidr" {
  type        = list(string)
  description = "CIDRs de subnets públicas"

  validation {
    condition     = alltrue([for cidr in var.public_subnets_cidr : can(cidrhost(cidr, 0))])
    error_message = "Cada subnet pública debe ser un CIDR válido."
  }
}

variable "private_subnets_cidr" {
  type        = list(string)
  description = "CIDRs de subnets privadas"

  validation {
    condition     = alltrue([for cidr in var.private_subnets_cidr : can(cidrhost(cidr, 0))])
    error_message = "Cada subnet privada debe ser un CIDR válido."
  }
}

variable "azs" {
  type        = list(string)
  description = "Availability zones a usar"

  validation {
    condition     = length(var.azs) > 0
    error_message = "Debes especificar al menos una availability zone."
  }
}
