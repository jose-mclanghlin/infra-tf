variable "vpc_cidr" {
  type        = string
  description = "CIDR principal de la VPC"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "El CIDR de la VPC debe ser valido (ej: 10.0.0.0/16)."
  }
}

variable "public_subnets_cidr" {
  type        = list(string)
  description = "CIDRs de subnets publicas"

  validation {
    condition     = alltrue([for cidr in var.public_subnets_cidr : can(cidrhost(cidr, 0))])
    error_message = "Cada subnet publica debe ser un CIDR válido."
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

# EC2 Variables
variable "ec2_instance_name" {
  description = "Name for the EC2 instance"
  type        = string
  default     = "plub-use1-dev-ec2"
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ec2_key_name" {
  description = "Key pair name for EC2 instance"
  type        = string
  default     = ""
}

variable "ec2_volume_size" {
  description = "Size of EBS volume in GB"
  type        = number
  default     = 20
}

variable "ec2_associate_public_ip" {
  description = "Whether to associate a public IP address"
  type        = bool
  default     = true
}
