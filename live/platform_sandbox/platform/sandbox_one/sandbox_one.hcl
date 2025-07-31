locals {
  # Load common variables
  team_vars = read_terragrunt_config(find_in_parent_folders("team.hcl"))

  # Extract commonly used variables
  common_identifier = "${local.team_vars.locals.common_identifier}-box"
}