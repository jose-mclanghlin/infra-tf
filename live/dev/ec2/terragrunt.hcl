include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/ec2"
}

include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
}

dependency "sg_server" {
  config_path = "../sg/sg-server"
}

dependency "subnets" {
  config_path = "../subnets"
}

inputs = {
  servers = {
    server-az1 = {
      ami              = "ami-123"
      instance_type    = "t3.micro"
      subnet_id        = dependency.subnets.outputs.private_subnet_ids[0]
      sg_ids           = [dependency.sg.outputs.sg_id]
      root_volume_size = 30
    }

    server-az2 = {
      ami              = "ami-123"
      instance_type    = "t3.micro"
      subnet_id        = dependency.subnets.outputs.private_subnet_ids[1]
      sg_ids           = [dependency.sg.outputs.sg_id]
      root_volume_size = 30
    }

    server-az3 = {
      ami              = "ami-123"
      instance_type    = "t3.micro"
      subnet_id        = dependency.subnets.outputs.private_subnet_ids[2]
      sg_ids           = [dependency.sg.outputs.sg_id]
      root_volume_size = 30
    }
  }
}