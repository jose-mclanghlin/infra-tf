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
}

dependency "subnet" {
  config_path = "../subnet"

  mock_outputs = {
    private_subnet_ids = [
      "subnet-mock-az1",
      "subnet-mock-az2"
    ]
  }
}

dependency "sg_server" {
  config_path = "../sg/sg-server"

  mock_outputs = {
    security_group_id = "sg-mock-123456"
  }
}

inputs = {
  name          = "dev-app"
  ami_id        = "ami-0e123456789abc"
  instance_type = "t3.micro"

  min     = 1
  desired = 2
  max     = 4
  subnets = dependency.subnet.outputs.private_subnet_ids
  security_groups = [dependency.sg_server.outputs.security_group_id]
}
