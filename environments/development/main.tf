module "vpc" {
  source                = "../../modules/vpc"
  cidr_block            = "10.0.0.0/16"
  name                  = "dev-vpc"
  public_subnets_cidr   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets_cidr  = ["10.0.101.0/24", "10.0.102.0/24"]
  azs                   = ["us-east-1a", "us-east-1b"]
}

module "ec2" {
  source = "../../modules/ec2"
  # ...variables específicas del módulo EC2
}

module "rds" {
  source = "../../modules/rds"
  # ...variables específicas del módulo RDS
}