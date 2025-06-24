include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "waf" {
  config_path = "${get_path_to_repo_root()}/network/platform/non_prod_waf"
  mock_outputs = {
    web_acl_id = "waf-1234abcd"
  }
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//network/cloudfront"
}

inputs = {
  name_prefix    = "static-site"
  bucket_name    = "cloud-city-bucket" # Enter existing bucket name
  aliases        = []
  waf_web_acl_id = dependency.waf.outputs.web_acl_id

  tags = {
    Environment = "non-prod"
    Project     = "StaticSite"
  }
}
