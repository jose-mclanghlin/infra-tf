module "vpc" {
  source                = "../../modules/vpc"
  cidr_block            = var.vpc_cidr
  name                  = "plub-use1-dev-vpc"
  public_subnets_cidr   = var.public_subnets_cidr
  private_subnets_cidr  = var.private_subnets_cidr
  azs                   = var.azs
}