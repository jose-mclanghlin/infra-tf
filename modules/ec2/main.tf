resource "aws_instance" "this" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_groups
  iam_instance_profile        = var.instance_profile
  key_name                    = var.key_name
  associate_public_ip_address = false
  user_data                   = var.user_data
  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}