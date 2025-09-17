module "vpc" {
  source     = "../../modules/vpc"
  cidr_block = "10.0.0.0/16"
  name       = "dev-vpc"
}

module "ec2" {
  source = "../../modules/ec2"
  # ...variables específicas del módulo EC2
}

module "rds" {
  source = "../../modules/rds"
  # ...variables específicas del módulo RDS
}