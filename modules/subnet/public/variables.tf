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
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = []
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

# Enable/disable NACL
variable "enable_nacl" {
  description = "Enable custom Network ACL for public subnets"
  type        = bool
  default     = true
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
