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
  name_prefix         = "dev-"
  
  # Configuración de subnets
  subnets = {
    public-1a = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "us-west-2a"
      public            = true
    }
    public-1b = {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "us-west-2b"
      public            = true
    }
    private-1a = {
      cidr_block        = "10.0.10.0/24"
      availability_zone = "us-west-2a"
      public            = false
    }
    private-1b = {
      cidr_block        = "10.0.11.0/24"
      availability_zone = "us-west-2b"
      public            = false
    }
  }
  
  # Configuración de NAT Gateway
  enable_nat_gateway   = true
  single_nat_gateway   = true
  
  # Tags
  tags = {
    Environment = "dev"
    Project     = "my-project"
    ManagedBy   = "terraform"
  }
}
