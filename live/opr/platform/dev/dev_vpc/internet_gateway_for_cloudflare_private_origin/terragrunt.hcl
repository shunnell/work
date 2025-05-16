# See adjacent README.md for details on why this exists.
include "root" {
  path = find_in_parent_folders("root.hcl")
}


dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_name = ""
    vpc_id   = ""
  }
}

terraform {
  source = "."
}

inputs = {
  vpc_name = dependency.vpc.outputs.vpc_name
  vpc_id   = dependency.vpc.outputs.vpc_id
}