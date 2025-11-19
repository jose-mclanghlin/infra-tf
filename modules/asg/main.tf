resource "aws_launch_template" "lt" {
  name_prefix   = "${var.name}-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type

  user_data = base64encode(var.user_data)

  network_interfaces {
    security_groups = var.security_groups
  }
}

resource "aws_autoscaling_group" "asg" {
  name                      = "${var.name}-asg"
  vpc_zone_identifier       = var.subnets
  desired_capacity          = var.desired
  min_size                  = var.min
  max_size                  = var.max

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }
}
