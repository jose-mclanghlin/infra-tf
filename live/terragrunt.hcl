remote_state {
  backend = "s3"
  config = {
    bucket         = "plub-use2-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "plub-use2-terraform-lock"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region  = try(var.aws_region, "us-east-2")
  profile = try(var.aws_profile, null)

  max_retries                 = 5
  skip_requesting_account_id  = false
}
EOF
}

inputs = {
  aws_region  = "us-east-2"
  aws_profile = "default"
}