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
  public_subnets_cidr = ["10.0.1.0/24", "10.0.2.0/24"]
  availability_zone   = "us-east-1a"
  name_prefix         = "dev"
  
  # Network ACL Configuration
  enable_nacl                     = true
  public_nacl_cidr               = "0.0.0.0/0"
  public_nacl_inbound_ports      = [80, 443, 22]  # HTTP, HTTPS, SSH
  public_nacl_inbound_ephemeral  = true
  public_nacl_outbound_ports     = [80, 443, 53]  # HTTP, HTTPS, DNS
  public_nacl_outbound_ephemeral = true
  
  tags = {
    Environment = "dev"
    Project     = "my-project"
    ManagedBy   = "terraform"
    Module      = "subnet"
  }
}
