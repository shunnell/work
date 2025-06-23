include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "alb" {
  config_path = "../non_prod_ingress_vpc/app_load_balancer"
  mock_outputs = {
    alb_arn = "mock-alb_arn"
  }
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//network/waf"
}

inputs = {
  name_prefix     = "non-prod-multitenant"
  resource_arn    = dependency.alb.outputs.alb_arn
  managed_rule_id = "AWSManagedRulesCommonRuleSet"

  tags = {
    Environment = "non-prod"
    Project     = "MultiTenantApp"
  }
}