terraform {
  backend "s3" {
    bucket         = "mi-terraform-state"
    key            = "global/s3/terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = "mi-terraform-lock"
    encrypt        = true
  }
}