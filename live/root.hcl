remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    bucket         = "plub-use1-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true
    dynamodb_table = "plub-use1-terraform-lock"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"

  contents = <<EOF
    provider "aws" {
      region                     = "us-east-1"
      max_retries                = 5
      skip_requesting_account_id = false
    }
    EOF
}

inputs = {
  # Global inputs can be added here if needed
}