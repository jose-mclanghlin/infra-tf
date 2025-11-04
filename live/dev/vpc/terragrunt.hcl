include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/vpc"
}

inputs = {
  name                 = "dev-vpc"
  cidr_block          = "10.0.0.0/16"
  enable_dns_support  = true
  enable_dns_hostnames = true
  
  tags = {
    Environment = "dev"
    Project     = "infra-tf"
    ManagedBy   = "terragrunt"
  }
}