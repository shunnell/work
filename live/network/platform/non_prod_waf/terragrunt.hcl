include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//network/waf"
}

inputs = {
  name_prefix     = "non-prod-multitenant"
  managed_rule_id = "AWSManagedRulesCommonRuleSet"

  tags = {
    Environment = "non-prod"
    Project     = "MultiTenantApp"
  }
}