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

  availability_zones = ["us-east-1a", "us-east-1b"]
  name_prefix        = "dev"

  # -------------------------------------------------
  # PUBLIC SUBNETS → EKS
  # -------------------------------------------------
  public_subnets_cidr = [
    { cidr = "10.0.10.0/24", name = "dev-eks-public-az1" },
    { cidr = "10.0.11.0/24", name = "dev-eks-public-az2" },
  ]

  # -------------------------------------------------
  # PRIVATE SUBNETS → EKS NODES / INTERNAL SERVICES
  # -------------------------------------------------
  create_private_subnets = true
  private_subnets_cidr = [
    { cidr = "10.0.20.0/24", name = "dev-eks-private-az1" },
    { cidr = "10.0.21.0/24", name = "dev-eks-private-az2" },
  ]

  # -------------------------------------------------
  # PRIVATE SUBNETS → RDS
  # -------------------------------------------------
  rds_subnets_cidr = [
    { cidr = "10.0.30.0/24", name = "dev-rds-private-az1" },
    { cidr = "10.0.31.0/24", name = "dev-rds-private-az2" },
  ]

  tags = {
    Environment = "dev"
    Project     = "infra-tf"
    ManagedBy   = "terragrunt"
    Module      = "subnet"
    Team        = "platform"
  }
}