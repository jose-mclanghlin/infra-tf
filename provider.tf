// See more: https://medium.com/devsecops-community/terraform-project-structure-a-step-by-step-guide-for-scalable-infrastructure-1e51e8029849
// See more: https://docs.aws.amazon.com/prescriptive-guidance/latest/terraform-aws-provider-best-practices/structure.html#repo-structure
// See more: https://medium.com/@bouachirhamza/structuring-terraform-projects-like-a-pro-modules-workspaces-best-practices-92c3f47df02b
// See more: https://stackoverflow.com/questions/66024950/how-to-organize-terraform-modules-for-multiple-environments
// See more: https://medium.com/@gupta.surender.1990/terraform-directory-structure-best-practices-build-for-scale-reuse-and-automation-6a2025cfd855
// See more: https://medium.com/byte-of-knowledge/understanding-terraform-and-terragrunt-a-detailed-guide-60f46ae32110
// See more: https://itnext.io/structuring-terraform-project-using-terragrunt-part-i-4c6e936c4858
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