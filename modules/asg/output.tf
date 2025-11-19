output "asg_name" {
  description = "The name of the Auto Scaling Group."
  value       = aws_autoscaling_group.asg.name
}

output "asg_arn" {
  description = "The ARN of the Auto Scaling Group."
  value       = aws_autoscaling_group.asg.arn
}

output "launch_template_id" {
  description = "The ID of the Launch Template used by the ASG."
  value       = aws_launch_template.lt.id
}

output "launch_template_latest_version" {
  description = "The latest version number of the Launch Template."
  value       = aws_launch_template.lt.latest_version
}

output "instance_security_groups" {
  description = "Security groups applied to EC2 instances launched by the ASG."
  value       = var.security_groups
}

output "subnet_ids" {
  description = "Subnets where the ASG instances will run."
  value       = var.subnets
}
output "asg_desired_capacity" {
  description = "The desired capacity of the Auto Scaling Group."
  value       = aws_autoscaling_group.asg.desired_capacity
}