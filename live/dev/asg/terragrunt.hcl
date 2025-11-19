include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path = find_in_parent_folders("terragrunt.hcl")
}

terraform {
  source = "../../../modules/asg"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id              = "vpc-12345678"
  }
}

dependency "subnets" {
  config_path = "../subnet"

  mock_outputs = {
    private_subnet_ids = [
      "subnet-mock-az1",
      "subnet-mock-az2"
    ]
  }
}

dependency "sg" {
  config_path = "../sg"

  mock_outputs = {
    security_group_id = "sg-mock"
  }
}

inputs = {
  name          = "dev-app"
  ami_id        = "ami-0e123456789abc"
  instance_type = "t3.micro"

  min     = 1
  desired = 2
  max     = 4
  subnets = dependency.subnets.outputs.private_subnet_ids
  security_groups = [dependency.sg.outputs.security_group_id]
}
