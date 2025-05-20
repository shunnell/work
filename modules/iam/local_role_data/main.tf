# Dummy provider requirement block to pull the arn_parse function's namespace into scope:
# https://github.com/hashicorp/terraform/issues/35753
terraform {
  required_providers {
    aws = {}
  }
}

locals {
  # Example: role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_e2346643e75b96cd
  # The AWS unique-id suffix doesn't have a published length, but it likely will not shrink:
  sso_role_regex = "^role/aws-reserved/sso[.]amazonaws[.]com/AWSReservedSSO_(\\S+)_[a-z0-9]{10,}$"
  iac_role_regex = "^role/(\\w+)$"
}

data "aws_iam_roles" "sso_roles" {
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

# TODO we should have a way (tags?) of retrieving an account's available IaC roles, ideally on a per-tenant-name basis.
#   For now, we just do terragrunter because it's the only truly supported IaC role.
data "aws_iam_role" "terragrunter" {
  # Data variable is used to make sure the role actually exists. This is a bit silly in the case of terragrunter, but it's
  # here as a precedent for finding other IaC roles in the future.
  name = "terragrunter"
  lifecycle {
    postcondition {
      condition     = can(regex(local.iac_role_regex, provider::aws::arn_parse(self.arn).resource))
      error_message = "Terragrunter role is assumed (has slashes in its name) and cannot be used as an IAM principal"
    }
  }
}

# See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_session_context#find-the-terraform-runners-source-role
data "aws_caller_identity" "current" {}

data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
  lifecycle {
    postcondition {
      condition     = can(regex(local.iac_role_regex, provider::aws::arn_parse(self.issuer_arn).resource))
      error_message = "Current session issuer role is assumed (has slashes in its name) and cannot be used as an IAM principal"
    }
  }
}

