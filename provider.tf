// See more: https://medium.com/devsecops-community/terraform-project-structure-a-step-by-step-guide-for-scalable-infrastructure-1e51e8029849
terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}