resource "aws_instance" "servers" {
  for_each = var.servers

  ami           = each.value.ami
  instance_type = each.value.instance_type
  subnet_id     = each.value.subnet_id
  vpc_security_group_ids = each.value.sg_ids

  root_block_device {
    volume_size = each.value.root_volume_size
    volume_type = "gp3"
  }
  tags = merge(
    {
      Name = "${var.name}-${each.key}"
    },
    var.tags
  )
}