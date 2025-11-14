# Basic variables for public subnets
variable "vpc_id" {
  description = "ID de la VPC donde crear las subnets"
  type        = string
}

variable "internet_gateway_id" {
  description = "ID del Internet Gateway"
  type        = string
}

variable "public_subnets_cidr" {
  description = "Lista de CIDRs para subnets públicas"
  type        = list(string)
  default     = []
}

variable "availability_zone" {
  description = "Availability zone única para todas las subnets"
  type        = string
  default     = "us-east-1a"
}

variable "name_prefix" {
  description = "Prefijo para nombres de recursos"
  type        = string
  default     = "public"
}

variable "tags" {
  description = "Tags para los recursos"
  type        = map(string)
  default     = {}
}

# CIDR allowed for inbound/outbound traffic (defaults to entire Internet)
variable "public_nacl_cidr" {
  description = "CIDR allowed for inbound and outbound traffic on the public NACL"
  type        = string
  default     = "0.0.0.0/0"
}

# Inbound ports allowed (HTTP/HTTPS by default)
variable "public_nacl_inbound_ports" {
  description = "Inbound ports allowed on the public NACL"
  type        = list(number)
  default     = [80, 443]
}

# Allow inbound ephemeral ports (1024–65535)
variable "public_nacl_inbound_ephemeral" {
  description = "Whether to allow inbound ephemeral ports"
  type        = bool
  default     = true
}

# Outbound ports allowed (HTTP/HTTPS by default)
variable "public_nacl_outbound_ports" {
  description = "Outbound ports allowed on the public NACL"
  type        = list(number)
  default     = [80, 443]
}

# Allow outbound ephemeral ports
variable "public_nacl_outbound_ephemeral" {
  description = "Whether to allow outbound ephemeral ports"
  type        = bool
  default     = true
}