include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/subnet"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id              = "vpc-00000000000000000"
    internet_gateway_id = "igw-00000000000000000"
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  vpc_id              = dependency.vpc.outputs.vpc_id
  internet_gateway_id = dependency.vpc.outputs.internet_gateway_id

  availability_zones = ["us-east-1a", "us-east-1b"]

  public_subnets_cidr = [
    { name = "dev-public-1a", cidr = "10.0.1.0/24" },
    { name = "dev-public-1b", cidr = "10.0.2.0/24" },
  ]

  create_private_subnets = true

  private_subnets_cidr = [
    { name = "dev-private-1a", cidr = "10.0.11.0/24" },
    { name = "dev-private-1b", cidr = "10.0.12.0/24" },
  ]

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
