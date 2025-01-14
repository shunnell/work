locals {
  # Load common variables
  account_vars  = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  platform_vars = read_terragrunt_config(find_in_parent_folders("platform.hcl"))

  # Extract commonly used variables
  instance_arn = "arn:aws:sso:::instance/ssoins-722334f2d9ffae26"
  default_tags = merge(local.account_vars.locals.account_tags, local.platform_vars.locals.team_tags)
}