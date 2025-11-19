include "root" {
  path = find_in_parent_folders("root.hcl")
}


terraform {
  source = "../../../../modules/ec2"
}

include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../../vpc"
}

dependency "sg_server" {
  config_path = "../../sg/sg-server"
}

dependency "subnets" {
  config_path = "../../subnets"

  mock_outputs = {
    private_subnet_ids = ["subnet-abcdef01", "subnet-abcdef02"]
  }
}

inputs = {
  name            = "private-server-1"
  ami             = "ami-xxxxxxxx"
  instance_type   = "t3.micro"

  subnet_id       = dependency.subnets.outputs.private_subnet_ids[0]

  security_groups = [
    dependency.sg_server.outputs.security_group_id
  ]

  instance_profile = "ec2-ssm-profile"

  user_data = <<EOF
#!/bin/bash
echo "Hello from private instance" > /var/www/index.html
EOF

  tags = {
    Environment = "dev"
    Project     = "infra-tf"
    ManagedBy   = "terragrunt"
    Module      = "vpc"
    Team        = "platform"
    LastModified = timestamp()
  }
}