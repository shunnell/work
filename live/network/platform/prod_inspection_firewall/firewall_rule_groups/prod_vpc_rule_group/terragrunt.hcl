include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules/network//network_firewall_rule_group"
}

locals {
  # Load common variables
  inspection_firewall_vars = read_terragrunt_config(find_in_parent_folders("prod_inspection_firewall.hcl"))

  # Extract commonly used variables
  common_identifier = local.inspection_firewall_vars.locals.common_identifier
}

dependency "prod_vpc" {
  config_path = "${get_repo_root()}/prod/platform/prod/prod_vpc/vpc"
  mock_outputs = {
    vpc_cidr_block = "mock-vpc-cidr-block"
  }
}

inputs = {
  name_prefix      = "${local.common_identifier}-prod-vpc-rule-group"
  home_net_cidrs   = [dependency.prod_vpc.outputs.vpc_cidr_block]
  enable_http_host = true
  # TODO: These domains are for use by the OPR3 app. As more tenants join prod, we'll have to design a solution which
  #   appropriately restricts their traffic on a per-tenant basis (perhaps ZScaler-based, or something inside EKS that
  #   filters based on namespace/tenancy).
  allowed_domains = yamldecode(file("opr_allowed_domains.yaml")).allowed_domains
}
