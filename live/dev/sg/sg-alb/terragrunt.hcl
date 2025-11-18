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

inputs = {
  name        = "alb-sg"
  description = "Security Group for Application Load Balancer"

  vpc_id = dependency.vpc.outputs.vpc_id

  # Ingress: ALB accepts traffic from the Internet
  ingress_rules = [
    {
      description = "Allow HTTP from anywhere"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Allow HTTPS from anywhere"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  # Egress: ALB must be able to send traffic to private instances
  # This is NOT restricted by security_groups here; it is controlled in the security group of private instances.
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
    Module        = "alb"
    Project       = "infra-tf"
    ManagedBy     = "terragrunt"
    Team          = "platform"
  }
}