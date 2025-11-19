variable "servers" {
  type = map(object({
    ami           = string
    instance_type = string
    subnet_id     = string
    sg_ids        = list(string)
    root_volume_size = number
  }))
}

variable "name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "tags" {
  description = "Additional resource tags"
  type        = map(string)
  default     = {}
}
