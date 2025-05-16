locals {
  # Load common variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  team_vars    = read_terragrunt_config(find_in_parent_folders("team.hcl"))

  # Extract commonly used variables
  common_identifier = "${local.account_vars.locals.account}-${local.team_vars.locals.team}-ivv"
}
