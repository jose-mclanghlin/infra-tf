variable "cidr_block" {
  description = "CIDR block para la VPC"
  type        = string
}

variable "name" {
  description = "Nombre de la VPC"
  type        = string
}

variable "public_subnets_cidr" {
  description = "Lista de CIDR blocks para las subnets públicas"
  type        = list(string)
}

variable "private_subnets_cidr" {
  description = "Lista de CIDR blocks para las subnets privadas"
  type        = list(string)
}

variable "azs" {
  description = "Lista de zonas de disponibilidad (AZs)"
  type        = list(string)
}