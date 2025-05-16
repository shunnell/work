locals {
  # Load common variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  team              = "data-platform"
  common_identifier = "${local.account_vars.locals.account}-${local.team}"

  team_tags = {
    team = local.team
  }
}