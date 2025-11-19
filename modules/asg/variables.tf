variable "name" {
  description = "Base name for all resources (ASG, Launch Template, tags)."
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for the Auto Scaling Group instances."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "desired" {
  description = "Desired capacity of the Auto Scaling Group."
  type        = number

  validation {
    condition     = var.desired >= 1
    error_message = "The desired capacity must be at least 1."
  }
}

variable "min" {
  description = "Minimum number of instances."
  type        = number
}

variable "max" {
  description = "Maximum number of instances."
  type        = number

  validation {
    condition     = var.max >= var.min
    error_message = "The max size must be greater than or equal to the min size."
  }
}

variable "subnets" {
  description = "List of subnet IDs where the Auto Scaling Group will deploy instances."
  type        = list(string)
}

variable "security_groups" {
  description = "List of security group IDs for the instances."
  type        = list(string)
}

variable "user_data" {
  description = "User data script for instance initialization."
  type        = string
  default     = ""
}