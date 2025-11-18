terraform {
  source = "../../../modules/ec2"
}

inputs = {
  ami_id             = "ami-xxxxxxxx" # Reemplaza por el AMI real
  instance_type      = "t3.micro"
  subnet_id          = "subnet-xxxxxxxx" # ID de la subnet donde lanzar la instancia
  security_group_ids = ["sg-xxxxxxxx"]   # Lista de SGs
  key_name           = "mi-keypair"      # Opcional, si usas SSH
  tags = {
    Name        = "dev-ec2"
    Environment = "dev"
  }
}
