include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path = find_in_parent_folders("terragrunt.hcl")
}

terraform {
  source = "../../../../modules/asg"
}

dependency "subnet" {
  config_path = "../../subnet"

  mock_outputs = {
    
    private_subnet_ids = [
      "subnet-mock-az1",
      "subnet-mock-az2"
    ]
  }
}

dependency "sg_server" {
  config_path = "../../sg/sg-server"

  mock_outputs = {
    security_group_id = "sg-mock-123456"
  }
}

inputs = {
  name          = "airflow-server"
  ami_id        = "ami-0fa3fe0fa7920f68e"
  instance_type = "t3.micro"

  min     = 1
  desired = 2
  max     = 4
  subnets = dependency.subnet.outputs.private_subnet_ids
  security_groups = [dependency.sg_server.outputs.security_group_id]

  user_data = file("${get_terragrunt_dir()}/user_data.sh.tpl")
}
