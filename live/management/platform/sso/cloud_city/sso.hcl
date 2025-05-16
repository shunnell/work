locals {
  # Load common variables
  account_vars  = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  platform_vars = read_terragrunt_config(find_in_parent_folders("team.hcl"))

  # Extract commonly used variables
  instance_arn              = "arn:aws:sso:::instance/ssoins-722334f2d9ffae26"
  identity_store_id         = "d-9067e2261c"
  standard_session_duration = "PT1H"
}
