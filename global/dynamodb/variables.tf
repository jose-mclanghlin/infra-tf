variable "dynamodb_table_name" {
  description = "Nombre de la tabla DynamoDB para locks de Terraform"
  type        = string
}

variable "environment" {
  description = "Nombre del entorno (dev, prod, etc.)"
  type        = string
  default     = "global"
}