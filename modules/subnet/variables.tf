# Variables básicas para subnets públicas
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
