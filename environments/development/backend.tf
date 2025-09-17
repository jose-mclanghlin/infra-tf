terraform {
  backend "s3" {
    bucket         = "mi-terraform-state-dev-infra-tf"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "mi-terraform-dev-lock"
    encrypt        = true
  }
}