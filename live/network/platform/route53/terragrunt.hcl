include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//route53"
}

dependency "shared_services_vpc" {
  config_path = "../shared_services_vpc/vpc"
  mock_outputs = {
    vpc_id                 = "",
    vpc_name               = "",
    interface_endpoint_ids = {}
  }
}

inputs = {
  domain                  = "us-east-1.cloud-city.ca.state.sbu"
  short_name              = "cloud-city"
  vpc_id                  = dependency.shared_services_vpc.outputs.vpc_id
  vpc_name                = dependency.shared_services_vpc.outputs.vpc_name
  interface_endpoints_ids = dependency.shared_services_vpc.outputs.interface_endpoint_ids
}