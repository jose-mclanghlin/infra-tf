variable "servers" {
  type = map(object({
    ami           = string
    instance_type = string
    subnet_id     = string
    sg_ids        = list(string)
    root_volume_size = number
    name         =  string
    tags         = map(string)
  }))
}