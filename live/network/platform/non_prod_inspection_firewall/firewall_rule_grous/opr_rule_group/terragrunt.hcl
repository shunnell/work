include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules/network//network_firewall_rule_group"
}

locals {
  # Load common variables
  inspection_firewall_vars = read_terragrunt_config(find_in_parent_folders("non_prod_inspection_firewall.hcl"))

  # Extract commonly used variables
  common_identifier = local.inspection_firewall_vars.locals.common_identifier
}

dependency "opr_dev_vpc" {
  config_path = "${get_repo_root()}/opr/platform/dev/dev_vpc/vpc"
  mock_outputs = {
    vpc_cidr_block = ""
  }
}

dependency "opr_staging_vpc" {
  config_path = "${get_repo_root()}/opr/platform/staging/staging_vpc/vpc"
  mock_outputs = {
    vpc_cidr_block = ""
  }
}

inputs = {
  name_prefix      = "${local.common_identifier}-opr-rule-group"
  home_net_cidrs   = ["172.41.0.0/23", dependency.opr_dev_vpc.outputs.vpc_cidr_block, dependency.opr_staging_vpc.outputs.vpc_cidr_block]
  enable_http_host = true
  allowed_domains  = yamldecode(file("allowed_domains.yaml")).allowed_domains
}
