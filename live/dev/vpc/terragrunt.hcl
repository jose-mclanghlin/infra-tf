include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path = find_in_parent_folders("terragrunt.hcl")
}

terraform {
  source = "../../../modules/vpc"
}

inputs = {
  name                 = "dev-vpc"
  cidr_block          = "10.0.0.0/16" # 65 536 IP addresses
  enable_dns_support  = true
  enable_dns_hostnames = true

  tags = {
    Environment = "dev"
    Project     = "infra-tf"
    ManagedBy   = "terragrunt"
  }
}