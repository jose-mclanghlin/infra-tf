module "s3_backend" {
  source              = "./s3"
  bucket_name         = "plub-use1-terraform-state"
  dynamodb_table_name = "plub-use1-terraform-lock"
  environment         = "global"
}