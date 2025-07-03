include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//route53"
}

inputs = {
  zone_name    = "us-east-1.cloud-city.ca.state.sbu"
  private_zone = false
  vpc_ids      = [] # no VPC associations for a public zone
  vpc_region   = "" # not used when private_zone=false
  comment      = "External DNS resolution zone"
  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
