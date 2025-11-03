module "s3_backend" {
  source              = "./s3"
  bucket_name         = "plub-use1-terraform-state"
}

module "dynamodb_table" {
  source              = "./dynamodb"
  dynamodb_table_name = "plub-use1-terraform-locks"
}