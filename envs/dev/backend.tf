terraform {
  backend "s3" {
    bucket         = "plub-use1-dev-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "plub-use1-dev-terraform-lock"
    encrypt        = true
  }
}