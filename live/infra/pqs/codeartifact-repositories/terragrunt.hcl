include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/../modules//codeartifact/repositories"
}

locals {
  team = read_terragrunt_config(find_in_parent_folders("team.hcl")).locals
}

inputs = {
  create_domain = true
  domain_name   = local.team.team
  repositories = [
    {
      name        = "maven-release"
      description = "Maven release repository"
    }
  ]
}