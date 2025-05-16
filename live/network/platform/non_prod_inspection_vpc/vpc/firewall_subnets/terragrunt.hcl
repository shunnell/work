include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//network/vpc/subnets"
}

dependency "vpc" {
  config_path = "../"
  mock_outputs = {
    private_subnets_by_az = {}
    vpc_id                = ""
  }
}

dependency "public_subnets" {
  config_path = "../public_subnets"
  mock_outputs = {
    subnets = {}
  }
}

inputs = {
  name               = "firewall"
  vpc_id             = dependency.vpc.outputs.vpc_id
  availability_zones = keys(dependency.vpc.outputs.private_subnets_by_az)
  width              = 4
  offset             = length(dependency.vpc.outputs.private_subnets_by_az) + length(dependency.public_subnets.outputs.subnets)
}
