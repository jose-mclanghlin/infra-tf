# Basic variables for private subnets
variable "vpc_id" {
  description = "ID of the VPC where the private subnets will be created"
  type        = string
}

variable "private_subnets_cidr" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = []
  
  validation {
    condition     = length(var.private_subnets_cidr) > 0
    error_message = "At least one CIDR block must be specified for private subnets."
  }
}

variable "availability_zones" {
  description = "List of Availability Zones where private subnets will be created"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
  
  validation {
    condition     = length(var.availability_zones) > 0
    error_message = "At least one availability zone must be specified."
  }
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs where NAT Gateways will be created"
  type        = list(string)
}

variable "name_prefix" {
  description = "Prefix used for naming resources"
  type        = string
  default     = "private"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
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

# Enable/disable NACL for private subnets
variable "enable_nacl" {
  description = "Enable custom Network ACL for private subnets"
  type        = bool
  default     = true
}

# NACL configuration for private subnets
variable "private_nacl_cidr" {
  description = "CIDR allowed for inbound and outbound traffic on the private NACL"
  type        = string
  default     = "10.0.0.0/16"  # Allow traffic within VPC by default
}

# Database ports for private subnets
variable "private_nacl_inbound_ports" {
  description = "Inbound ports allowed on the private NACL (database, app servers, etc.)"
  type        = list(number)
  default     = [3306, 5432, 6379]  # MySQL, PostgreSQL, Redis
}

# Allow inbound ephemeral ports for private subnets
variable "private_nacl_inbound_ephemeral" {
  description = "Whether to allow inbound ephemeral ports"
  type        = bool
  default     = true
}

# Outbound ports for private subnets (typically HTTP/HTTPS for updates)
variable "private_nacl_outbound_ports" {
  description = "Outbound ports allowed on the private NACL"
  type        = list(number)
  default     = [80, 443]  # HTTP, HTTPS for package updates
}

# Allow outbound ephemeral ports
variable "private_nacl_outbound_ephemeral" {
  description = "Whether to allow outbound ephemeral ports"
  type        = bool
  default     = true
}
