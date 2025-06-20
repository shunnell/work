include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//network/network_firewall"
}

locals {
  # Load common variables
  inspection_firewall_vars = read_terragrunt_config(find_in_parent_folders("non_prod_inspection_firewall.hcl"))

  # Extract commonly used variables
  common_identifier = local.inspection_firewall_vars.locals.common_identifier
  vpc_name          = local.inspection_firewall_vars.locals.vpc_name
}

dependency "vpc" {
  config_path = "../../non_prod_inspection_vpc/vpc"
  mock_outputs = {
    vpc_id = "mock-vpc-id"
  }
}

dependency "firewall_subnets" {
  config_path = "../../non_prod_inspection_vpc/vpc/firewall_subnets"
  mock_outputs = {
    subnets = {}
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

dependency "infra_rule_group" {
  config_path = "../firewall_rule_groups/infra_rule_group"
  mock_outputs = {
    rule_group_arn = "mock-rule-group-arn"
  }
}

dependency "opr_rule_group" {
  config_path = "../firewall_rule_groups/opr_rule_group"
  mock_outputs = {
    rule_group_arn = "mock-rule-group-arn"
  }
}

dependency "shared_rule_group" {
  config_path = "../firewall_rule_groups/shared_rule_group"
  mock_outputs = {
    rule_group_arn = "mock-rule-group-arn"
  }
}

dependencies {
  paths = [
    "../firewall_rule_groups/infra_rule_group",
    "../firewall_rule_groups/opr_rule_group",
    "../firewall_rule_groups/shared_rule_group"
  ]
}

inputs = {
  vpc_id          = dependency.vpc.outputs.vpc_id
  subnet_mappings = [for subnet in values(dependency.firewall_subnets.outputs.subnets) : subnet.subnet_id]
  name_prefix     = "${local.common_identifier}-firewall"
  rule_group_arns = [
    dependency.infra_rule_group.outputs.rule_group_arn,
    dependency.opr_rule_group.outputs.rule_group_arn,
    dependency.shared_rule_group.outputs.rule_group_arn
  ]
  alert_log_group_name = dependency.alert_log_group.outputs.cloudwatch_log_group_name
  flow_log_group_name  = dependency.flow_log_group.outputs.cloudwatch_log_group_name
  tls_log_group_name   = dependency.tls_log_group.outputs.cloudwatch_log_group_name
}
