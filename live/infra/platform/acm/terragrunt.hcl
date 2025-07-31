include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "team" {
  path = find_in_parent_folders("team.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//acm/"
}

inputs = {
  certificates = {
    gitlab = {
      domain_name               = "gitlab.test.cloud-city"
      subject_alternative_names = []
      key_algorithm             = "RSA_2048"
      certificate_authority_arn = "arn:aws:acm-pca:us-east-1:430118816674:certificate-authority/ec9f73e8-7280-4952-9e27-52445911aed7" # Private CA ARN
      tags = merge(
        local.account_vars.locals.account_tags,
        local.team_tags,
        {
          Component   = "certificate"
          Purpose     = "ssl-tls"
          Type        = "private"
          Application = "gitlab"
        }
      )
    }
    #example of adding another cert:    
    #    api = {
    #      domain_name               = "api.test.cloud-city"
    #      subject_alternative_names = []
    #      key_algorithm             = "RSA_2048"
    #      certificate_authority_arn = "arn:aws:acm-pca:us-east-1:430118816674:certificate-authority/ec9f73e8-7280-4952-9e27-52445911aed7" # Private CA ARN
    #      tags = merge(
    #        local.account_vars.locals.account_tags,
    #        local.team_tags,
    #        {
    #          Component   = "certificate"
    #          Purpose     = "ssl-tls"
    #          Type        = "private"
    #          Application = "api"
    #        }
    #      )
    #    }
  }
}

locals {
  # Load common variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  team_vars    = read_terragrunt_config(find_in_parent_folders("team.hcl"))

  team_tags = local.team_vars.locals.team_tags
}