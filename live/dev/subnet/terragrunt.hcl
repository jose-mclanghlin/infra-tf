include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path = find_in_parent_folders("terragrunt.hcl")
}

terraform {
  source = "../../../modules/subnet"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id              = "vpc-12345678"
    internet_gateway_id = "igw-12345678"
  }
}

inputs = {
  vpc_id              = dependency.vpc.outputs.vpc_id
  internet_gateway_id = dependency.vpc.outputs.internet_gateway_id

  public_subnets_cidr = [
    { cidr = "10.0.10.0/24", name = "dev-public-web-az1" },
    { cidr = "10.0.11.0/24", name = "dev-public-web-az2" },
  ]

  availability_zones = ["us-east-1a", "us-east-1b"]
  name_prefix        = "dev"

  tags = {
    Environment = "dev"
    Project     = "infra-tf"
    ManagedBy   = "terragrunt"
    Module      = "subnet"
  }
}