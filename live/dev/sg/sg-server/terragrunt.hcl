terraform {
  source = "../../../../modules/sg"
}

include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../../vpc"

   mock_outputs = {
    vpc_id              = "vpc-12345678"
  }
}

inputs = {
  name        = "sg-server"
  description = "Security Group for EC2 instances"

  vpc_id = dependency.vpc.outputs.vpc_id

  ingress_rules = [
    {
      description = "SSH from your IP"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["YOUR_PUBLIC_IP/32"]
    }
  ]

  egress_rules = [
    {
      description = "All outbound traffic allowed"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = {
    Environment = "dev"
    Module   = "ec2"
    Project  = "infra-tf"
    ManagedBy   = "terragrunt"
    LastModified = timestamp()
  }
}