variable "name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "ami" {
  description = "AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Private subnet where the instance will run"
  type        = string
}

variable "security_groups" {
  description = "Security Groups to attach"
  type        = list(string)
}

variable "instance_profile" {
  description = "IAM instance profile to attach"
  type        = string
  default     = null
}

variable "key_name" {
  description = "EC2 Key Pair (optional)"
  type        = string
  default     = null
}

variable "user_data" {
  description = "User data script"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional resource tags"
  type        = map(string)
  default     = {}
}
