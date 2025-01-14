include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules/network/network_firewall"
}

locals {
  # Load common variables
  inspection_firewall_vars = read_terragrunt_config(find_in_parent_folders("non_prod_inspection_firewall.hcl"))

  # Extract commonly used variables
  common_identifier = local.inspection_firewall_vars.locals.common_identifier
  vpc_name          = local.inspection_firewall_vars.locals.vpc_name
  default_tags      = local.inspection_firewall_vars.locals.default_tags
}

dependency "vpc" {
  config_path = "../../non_prod_inspection_vpc/vpc"
  mock_outputs = {
    vpc_id = "mock-vpc-id"
  }
}

dependency "firewall_subnets" {
  config_path = "../../non_prod_inspection_vpc/firewall_subnets"
  mock_outputs = {
    subnet_ids = ["mock-private-subnet-id-1", "mock-private-subnet-id-2", "mock-private-subnet-id-3"]
  }
}

dependency "alert_log_group" {
  config_path = "../../non_prod_inspection_firewall/tls_logs_group"
  mock_outputs = {
    cloudwatch_log_group_name = "mock-alert-log-group"
  }
}

dependency "flow_log_group" {
  config_path = "../../non_prod_inspection_firewall/flow_logs_group"
  mock_outputs = {
    cloudwatch_log_group_name = "mock-flow-log-group"
  }
}

dependency "tls_log_group" {
  config_path = "../../non_prod_inspection_firewall/tls_logs_group"
  mock_outputs = {
    cloudwatch_log_group_name = "mock-tls-log-group"
  }
}


inputs = {
  vpc_id               = dependency.vpc.outputs.vpc_id
  subnet_mappings      = dependency.firewall_subnets.outputs.subnet_ids
  home_net_cidrs       = ["172.16.0.0/12"]
  name_prefix          = "${local.common_identifier}-firewall"
  allowed_domains      = [".amazonaws.com"]
  alert_log_group_name = dependency.alert_log_group.outputs.cloudwatch_log_group_name
  flow_log_group_name  = dependency.flow_log_group.outputs.cloudwatch_log_group_name
  tls_log_group_name   = dependency.tls_log_group.outputs.cloudwatch_log_group_name
  tags                 = local.default_tags
}
