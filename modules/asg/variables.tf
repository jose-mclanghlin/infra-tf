variable "name" {}
variable "ami_id" {}
variable "instance_type" {}
variable "desired" {}
variable "min" {}
variable "max" {}
variable "subnets" { type = list(string) }
variable "security_groups" { type = list(string) }
variable "user_data" { default = "" }
