include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules/route53/internal_external_route53"
}

dependency "shared_services_vpc" {
  config_path = "../../shared_services_vpc/vpc"
  mock_outputs = {
    vpc_id                 = ""
    vpc_name               = ""
    interface_endpoint_ids = {}
  }
}

inputs = {
  zone_name  = "cloud-city"
  vpc_ids    = [dependency.shared_services_vpc.outputs.vpc_id]
  vpc_region = "us-east-1"
  comment    = "Internal DNS resolution zone"
  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
