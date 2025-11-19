include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/sg"
}

include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../../vpc"

  mock_outputs = {
    vpc_id = "vpc-12345678"
  }
}

dependency "sg-alb" {
  config_path = "../../sg/sg-alb"

  mock_outputs = {
    security_group_id = "sg-99999999"
  }
}

inputs = {
  name        = "server-sg-priv"
  description = "Security Group for private EC2 instances"

  vpc_id = dependency.vpc.outputs.vpc_id

  # Ingress: ONLY traffic from the Load Balancer
  ingress_rules = [
    {
      description     = "Allow HTTP from ALB"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = [dependency.sg-alb.outputs.security_group_id]
    }
  ]

  # Egress: all traffic allowed (recommended for private instances)
  egress_rules = [
    {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = {
    Environment   = "dev"
    Module        = "sg-servers"
    Project       = "infra-tf"
    ManagedBy     = "terragrunt"
  }
}