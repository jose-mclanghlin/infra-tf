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
  servers = {
    server-az1 = {
      ami              = "ami-123"
      instance_type    = "t3.micro"
      subnet_id        = dependency.subnet.outputs.private_subnet_ids[0]
      sg_ids           = [dependency.sg_server.outputs.security_group_id]
      root_volume_size = 30
    }
    server-az2 = {
      ami              = "ami-123"
      instance_type    = "t3.micro"
      subnet_id        = dependency.subnet.outputs.private_subnet_ids[1]
      sg_ids           = [dependency.sg_server.outputs.security_group_id]
      root_volume_size = 30
    }
  }
}