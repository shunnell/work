locals {
  # Parse the path to get environment, region, etc.
  path_parts  = split("/", path_relative_to_include())
  account_dir = "${get_repo_root()}/${local.path_parts[0]}"

  account                  = read_terragrunt_config("${local.account_dir}/account.hcl")
  team                     = read_terragrunt_config("${local.account_dir}/${local.path_parts[1]}/team.hcl")
  infra                    = read_terragrunt_config("${get_repo_root()}/infra/account.hcl")
  terragrunter_role_arn    = local.account.locals.terragrunter_role_arn
  terragrunter_external_id = local.infra.locals.terragrunter_external_id

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

# NOTE re: role assumption: we assume the "infra" terragrunter role "outside" of terragrunt/terraform, in bespinctl.
# We then use the allowed_account_ids fields as an "idiot check" to make sure misconfiguration or direct invocation of
# terragrunt doesn't point at the wrong account. We technically could do all the role assume config here--and at one
# point we did, even the "chained" assume from infra terragrunter to the target account terragrunter. However, that
# change resulted in intermittent, confusing failures from Terraform in assuming the role, especially on Ubuntu
# workstations. Switching to managing the SSO->terragrunter assume chain outside of tf/tg made those issues go away; the
# working theory as to why things broke is that Terraform/Terragrunt have internal caches of assumed-role credentials
# that it doesn't clear or expire properly between tf/tg invocations, causing issues. Perhaps future versions of tf/tg
# will resolve these issues.

# Remote state configuration
remote_state {
  backend = "s3"
  config = {
    bucket              = "dos-cloudcity-infra-terraform-state"
    key                 = "${path_relative_to_include()}/terraform.tfstate"
    region              = local.infra.locals.region
    encrypt             = true
    dynamodb_table      = "dos-cloudcity-infra-terraform-locks"
    allowed_account_ids = [local.infra.locals.account_id]
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
  contents  = <<-EOF
    provider "time" {}
    provider "aws" {
      region = "${local.account.locals.region}"
      allowed_account_ids = ["${local.account.locals.account_id}"]
      assume_role {
        role_arn = "${local.terragrunter_role_arn}"
        external_id  = "${local.terragrunter_external_id}"
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
      region = "${local.infra.locals.region}"
      allowed_account_ids = ["${local.infra.locals.account_id}"]
      default_tags {
        tags = ${jsonencode(local.common_tags)}
      }
    }
  EOF
}
