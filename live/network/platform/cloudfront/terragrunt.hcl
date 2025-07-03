include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = [
    "${get_path_to_repo_root()}/network/platform/non_prod_ingress_vpc/app_load_balancer",
    "${get_path_to_repo_root()}/network/platform/non_prod_waf",
  ]
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//network/cloudfront"
}

inputs = {
  name_prefix         = "static-site"
  default_root_object = "index.html"
  error_document      = "error.html"
  aliases             = []

  tags = {
    Environment = "non-prod"
    Project     = "StaticSite"
  }
}
