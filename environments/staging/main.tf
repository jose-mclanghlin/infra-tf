module "vpc" {
  source = "../../modules/vpc"
  # ...variables específicas del módulo VPC
}

module "ec2" {
  source = "../../modules/ec2"
  # ...variables específicas del módulo EC2
}

module "rds" {
  source = "../../modules/rds"
  # ...variables específicas del módulo RDS
}