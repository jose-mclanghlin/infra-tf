output "table_name" {
  description = "Nombre de la tabla DynamoDB creada"
  value       = aws_dynamodb_table.this.name
}

output "table_arn" {
  description = "ARN de la tabla DynamoDB"
  value       = aws_dynamodb_table.this.arn
}