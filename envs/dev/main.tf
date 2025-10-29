module "vpc" {
  source = "../../modules/vpc"
  vpc_config = {
    cidr_block            = "10.10.0.0/16"
    name                  = "plub-use1-dev-vpc"
    public_subnets_cidr   = ["10.10.1.0/24", "10.10.2.0/24"]
    private_subnets_cidr  = ["10.10.101.0/24", "10.10.102.0/24"]
    azs                   = ["us-east-1a", "us-east-1b"]
  }
}