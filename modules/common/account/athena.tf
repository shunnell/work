# AWS Athena comes with a pre-provisioned, non-deletable "primary" workgroup in all regions. Security Hub complains
# that this workgroup does not have logging configured:
# https://docs.aws.amazon.com/securityhub/latest/userguide/athena-controls.html#athena-1

# This workgroup comes with each AWS account and cannot be deleted. To deal with that and still ensure it is disabled,
# we check in the "import" block below to tell Terraform that it exists.
# Checking in "import" blocks should ordinarily never be done, as it can be quite dangerous!
import {
  id = "primary"
  to = aws_athena_workgroup.default_workgroup
}

resource "aws_athena_workgroup" "default_workgroup" {
  name  = "primary"
  state = "DISABLED"
  lifecycle {
    # Since the primary workgroup cannot be deleted, attempts to destroy it via Terraform should fail. If you follow
    # such a failure and end up here, consider:
    # 1. Why are you trying to destroy part of an account baseline? If the account is being decommissioned, just delete
    #    the entire AWS account.
    # 2. If you must destroy this resource according to Terraform for some reason, use "terragrunt state rm" or
    #    "terraform rm" to delete it manually, then comment out management of that resource in this file.
    prevent_destroy = true
  }
}
