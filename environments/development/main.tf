module "vpc" {
  source                = "../../modules/vpc"
  cidr_block            = var.vpc_cidr
  name                  = "plub-use1-dev-vpc"
  public_subnets_cidr   = var.public_subnets_cidr
  private_subnets_cidr  = var.private_subnets_cidr
  azs                   = var.azs
}

module "ec2" {
  source = "../../modules/ec2"
  
  instance_name               = var.ec2_instance_name
  instance_type              = var.ec2_instance_type
  key_name                   = var.ec2_key_name
  subnet_id                  = module.vpc.public_subnets[0]  # Using first public subnet
  associate_public_ip_address = var.ec2_associate_public_ip
  volume_size                = var.ec2_volume_size
  environment                = "development"
  
  tags = {
    Project     = "plub"
    Environment = "development"
    Terraform   = "true"
  }
  
  # Basic user data script to install updates
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from Development EC2!</h1>" > /var/www/html/index.html
    EOF
}

module "rds" {
  source = "../../modules/rds"
  # ...specific variables of the RDS module
}