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

  # Infra account vars
  infra_account = read_terragrunt_config("${get_path_to_repo_root()}/infra/platform/admin/admin_vpc/admin_vpc.hcl").locals
}


inputs = {
  name_prefix      = "${local.common_identifier}-infra-rule-group"
  home_net_cidrs   = ["172.16.0.0/16", local.infra_account.vpc_cidr_block]
  enable_http_host = true
  capacity         = 1000
  allowed_domains  = yamldecode(file("allowed_domains.yaml")).allowed_domains
}
