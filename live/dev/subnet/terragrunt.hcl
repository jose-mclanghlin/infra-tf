include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/subnet"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id              = "vpc-fake-id"
    internet_gateway_id = "igw-fake-id"
  }
}

inputs = {
  vpc_id      = dependency.vpc.outputs.vpc_id
  name_prefix = "dev"
  
  public_subnets = [
    {
      cidr_block              = "10.0.1.0/24"
      availability_zone       = "us-east-1a"
      map_public_ip_on_launch = true
      name                    = "dev-public-1"
      tags = {
        Tier = "Public"
      }
    },
    {
      cidr_block              = "10.0.2.0/24"
      availability_zone       = "us-east-1b"
      map_public_ip_on_launch = true
      name                    = "dev-public-2"
      tags = {
        Tier = "Public"
      }
    }
  ]

  # Private subnets configuration
  private_subnets = [
    {
      cidr_block        = "10.0.101.0/24"
      availability_zone = "us-east-1a"
      name              = "dev-private-1"
      tags = {
        Tier = "Private"
      }
    },
    {
      cidr_block        = "10.0.102.0/24"
      availability_zone = "us-east-1b"
      name              = "dev-private-2"
      tags = {
        Tier = "Private"
      }
    }
  ]

  # Database subnets configuration (optional)
  database_subnets = [
    {
      cidr_block        = "10.0.201.0/24"
      availability_zone = "us-east-1a"
      name              = "dev-db-1"
      tags = {
        Tier = "Database"
      }
    },
    {
      cidr_block        = "10.0.202.0/24"
      availability_zone = "us-east-1b"
      name              = "dev-db-2"
      tags = {
        Tier = "Database"
      }
    }
  ]

  # Internet Gateway from VPC module
  internet_gateway_id = dependency.vpc.outputs.internet_gateway_id

  # Route table options
  create_public_route_table   = true
  create_private_route_table  = true
  create_database_route_table = true

  # NAT Gateway options
  create_nat_gateway = true
  single_nat_gateway = false # One NAT Gateway per AZ for high availability

  # Database subnet group
  create_database_subnet_group = true
  database_subnet_group_name   = "dev-db-subnet-group"

  tags = {
    Environment = "dev"
    Project     = "infra-tf"
    ManagedBy   = "terragrunt"
  }
}