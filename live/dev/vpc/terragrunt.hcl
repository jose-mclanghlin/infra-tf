include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/vpc"
}

inputs = {
  vpc_config = {
    name                 = "dev-vpc"
    cidr_block           = "10.2.0.0/16"
    azs                  = ["us-east-1a", "us-east-1b"]
    public_subnets_cidr  = ["10.2.1.0/24", "10.2.2.0/24"]
    private_subnets_cidr = ["10.2.101.0/24", "10.2.102.0/24"]
  }
}