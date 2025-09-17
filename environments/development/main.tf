module "vpc" {
  source                = "../../modules/vpc"
  cidr_block            = var.vpc_cidr
  name                  = "dev-vpc"
  public_subnets_cidr   = var.public_subnets_cidr
  private_subnets_cidr  = var.private_subnets_cidr
  azs                   = var.azs
}

module "ec2" {
  source = "../../modules/ec2"
  # ...variables específicas del módulo EC2
}

module "rds" {
  source = "../../modules/rds"
  # ...variables específicas del módulo RDS
}