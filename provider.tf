// See more: https://medium.com/devsecops-community/terraform-project-structure-a-step-by-step-guide-for-scalable-infrastructure-1e51e8029849
// See more: https://docs.aws.amazon.com/prescriptive-guidance/latest/terraform-aws-provider-best-practices/structure.html#repo-structure
// See more: https://medium.com/@bouachirhamza/structuring-terraform-projects-like-a-pro-modules-workspaces-best-practices-92c3f47df02b
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