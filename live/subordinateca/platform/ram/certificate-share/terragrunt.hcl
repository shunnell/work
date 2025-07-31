include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "team" {
  path = find_in_parent_folders("team.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//ram/"
}

inputs = {
  name                      = "private-ca-share"
  allow_external_principals = false
  resource_arns             = ["arn:aws:acm-pca:us-east-1:430118816674:certificate-authority/ec9f73e8-7280-4952-9e27-52445911aed7"] # Private CA ARN
  principal_arns            = ["381492150796"]                                                                                      # Platform/Infra account ID

  tags = merge(
    local.account_vars.locals.account_tags,
    local.team_tags,
    {
      Component = "private-ca-share"
      Purpose   = "share-private-ca"
    }
  )
}

locals {
  # Load common variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  team_vars    = read_terragrunt_config(find_in_parent_folders("team.hcl"))

  team_tags = local.team_vars.locals.team_tags
}