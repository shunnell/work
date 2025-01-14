include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules/iam/sso_permission_set"
}

locals {
  # Load variables
  sso_vars = read_terragrunt_config(find_in_parent_folders("sso.hcl"))

  # Extract commonly used variables
  instance_arn = local.sso_vars.locals.instance_arn
  default_tags = local.sso_vars.locals.default_tags
}


inputs = {
  permission_set_name = "Cloud_City_Dev_Group"
  description         = "Cloud City Dev Group Permission Set"
  instance_arn        = local.instance_arn
  session_duration    = "PT1H"
  managed_policy_arns = []
  tags                = local.default_tags
} 