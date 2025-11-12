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
  
  subnet_config = {
    name                   = "prod-network"
    public_subnets_cidr   = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
    private_subnets_cidr  = ["10.1.10.0/24", "10.1.11.0/24", "10.1.12.0/24"]
    azs                   = ["us-west-2a", "us-west-2b", "us-west-2c"]
  }
  
  enable_nat_gateway = true
  
  tags = {
    Environment = "prod"
    Project     = "my-project"
    ManagedBy   = "terraform"
    Module      = "subnet"
    CostCenter  = "production"
  }
}