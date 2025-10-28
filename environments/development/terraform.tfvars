vpc_cidr = "10.10.0.0/16"
public_subnets_cidr  = ["10.10.1.0/24", "10.10.2.0/24"]
private_subnets_cidr = ["10.10.101.0/24", "10.10.102.0/24"]
azs = ["us-east-1a", "us-east-1b"]

# EC2 Configuration
ec2_instance_name = "plub-use1-dev-web-server"
ec2_instance_type = "t3.micro"
ec2_key_name = ""  # Add your key pair name here
ec2_volume_size = 20
ec2_associate_public_ip = true