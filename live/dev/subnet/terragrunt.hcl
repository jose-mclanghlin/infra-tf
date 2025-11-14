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
  
  # Public subnets configuration
  public_subnets_cidr = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  availability_zones  = ["us-east-1a", "us-east-1b"]
  name_prefix         = "dev"
  
  # Private subnets configuration
  create_private_subnets = true
  private_subnets_cidr   = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
  
  # NAT Gateway configuration
  enable_nat_gateway = true
  single_nat_gateway = false  # Multiple NAT Gateways for HA
  
  # Public Network ACL Configuration
  enable_nacl                     = true
  public_nacl_cidr               = "0.0.0.0/0"
  public_nacl_inbound_ports      = [80, 443, 22]  # HTTP, HTTPS, SSH
  public_nacl_inbound_ephemeral  = true
  public_nacl_outbound_ports     = [80, 443, 53]  # HTTP, HTTPS, DNS
  public_nacl_outbound_ephemeral = true
  
  # Private Network ACL Configuration
  enable_private_nacl                = true
  private_nacl_cidr                 = "10.0.0.0/16"  # Allow traffic within VPC
  private_nacl_inbound_ports        = [3306, 5432, 6379, 8080]  # MySQL, PostgreSQL, Redis, App
  private_nacl_inbound_ephemeral    = true
  private_nacl_outbound_ports       = [80, 443]  # HTTP, HTTPS for updates
  private_nacl_outbound_ephemeral   = true
  
  tags = {
    Environment = "dev"
    Project     = "infra-tf"
    ManagedBy   = "terragrunt"
    Module      = "subnet"
  }
}