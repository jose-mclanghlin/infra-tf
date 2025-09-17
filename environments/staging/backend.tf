terraform {
  backend "s3" {
    bucket         = "mi-terraform-state-infra-tf"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "mi-terraform-lock"
    encrypt        = true
  }
}