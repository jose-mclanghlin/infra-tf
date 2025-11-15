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

# ===== PRIVATE SUBNET VARIABLES =====

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

# NAT Gateway configuration
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets internet access"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets (cost optimization)"
  type        = bool
  default     = false
}

# Private NACL configuration
variable "enable_private_nacl" {
  description = "Enable custom Network ACL for private subnets"
  type        = bool
  default     = true
}

variable "private_nacl_cidr" {
  description = "CIDR allowed for inbound and outbound traffic on the private NACL"
  type        = string
  default     = "10.0.0.0/16" # Allow traffic within VPC by default
}

variable "private_nacl_inbound_ports" {
  description = "Inbound ports allowed on the private NACL (database, app servers, etc.)"
  type        = list(number)
  default     = [3306, 5432, 6379] # MySQL, PostgreSQL, Redis
}

variable "private_nacl_inbound_ephemeral" {
  description = "Whether to allow inbound ephemeral ports for private subnets"
  type        = bool
  default     = true
}

variable "private_nacl_outbound_ports" {
  description = "Outbound ports allowed on the private NACL"
  type        = list(number)
  default     = [80, 443] # HTTP, HTTPS for package updates
}

variable "private_nacl_outbound_ephemeral" {
  description = "Whether to allow outbound ephemeral ports for private subnets"
  type        = bool
  default     = true
}
