include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path = find_in_parent_folders("terragrunt.hcl")
}

terraform {
  source = "../../../modules/subnet/public"
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
  public_subnets_cidr = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]  # Nuevo rango de CIDRs
  availability_zones  = ["us-east-1a", "us-east-1b"]  # Lista de AZs
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
    Project     = "infra-tf"
    ManagedBy   = "terragrunt"
    Module      = "subnet"
  }
}