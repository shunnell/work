# Root terragrunt.hcl
locals {
  # Default AWS region for all resources
  default_region = "us-east-1"
  # Parse the path to get environment, region, etc.
  path_parts  = split("/", path_relative_to_include())
  account_dir = "${get_repo_root()}/${local.path_parts[0]}"

  account = read_terragrunt_config("${local.account_dir}/account.hcl")
  team    = read_terragrunt_config("${local.account_dir}/${local.path_parts[1]}/team.hcl")
  infra   = read_terragrunt_config("${get_repo_root()}/infra/account.hcl")

  account_region              = lookup(local.account.locals, "region", local.default_region)
  terragrunter_role_arn       = local.account.locals.terragrunter_role_arn
  infra_terragrunter_role_arn = local.infra.locals.terragrunter_role_arn

  # Common tags for all resources
  common_tags = merge(
    {
      ManagedBy = "Terragrunt"
      Project   = "CloudCity"
      customer  = "CA-BESPIN-AWS"
      sys-name  = "pending"
    },
    local.account.locals.account_tags,
    local.team.locals.team_tags
  )
}

terraform_version_constraint  = "= 1.11.4"
terragrunt_version_constraint = "= 0.77.11"

# Remote state configuration
remote_state {
  backend = "s3"
  config = {
    bucket         = "dos-cloudcity-infra-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.default_region
    encrypt        = true
    dynamodb_table = "dos-cloudcity-infra-terraform-locks"
    assume_role = {
      role_arn = local.infra_terragrunter_role_arn
    }
    # DO NOT ADD 'profile =', not even temporarily without checking it in!
    # If your plan/apply doesn't work without that, the problem needs to be fixed elsewhere; seek help.
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  # begin template
  contents = <<-EOF
    provider "time" {}
    provider "aws" {
      region = "${local.account_region}"
      assume_role {
        role_arn = "${local.terragrunter_role_arn}"
      }
      default_tags {
        tags = ${jsonencode(local.common_tags)}
      }
      # DO NOT ADD 'profile =', not even temporarily without committing it!
      # If your plan/apply doesn't work without that, the problem needs to be fixed elsewhere; seek help.
    }

    # Make an aliased, non-default AWS provider instance that is always pointed at the infra account. This is used to
    # enable IaC code to pull Helm charts or retrieve other infra-account data, even when applying IaC in a different
    # AWS account. Use this provider alias with extreme care, and only if you know what you are doing.
    provider "aws" {
      alias = "infra_terragrunter_provider"
      region = "${local.account_region}"
      assume_role {
        role_arn = "${local.infra_terragrunter_role_arn}"
      }
      default_tags {
        tags = ${jsonencode(local.common_tags)}
      }
    }
  EOF
  # end template
}
