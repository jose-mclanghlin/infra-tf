include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/vpc"
}

inputs = {
  vpc_config = {
    name                 = "prod-vpc"
    cidr_block           = "10.0.0.0/16"
    azs                  = ["us-east-1a", "us-east-1b"]
    public_subnets_cidr  = ["10.0.1.0/24", "10.0.2.0/24"]
    private_subnets_cidr = ["10.0.101.0/24", "10.0.102.0/24"]
  }
}