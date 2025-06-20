# We use 'local_role_data' directly here rather than requiring it be passed as an input, since it is VERY VERY BAD
# if an accidental input mistake results in a key with a policy that doesn't permit anyone to manage it; that key
# can't be deleted or changed by anyone, it lasts forever. Avoiding that risk is worth breaking separation of concerns
# a bit and fetching 'local_role_data' multiple times.
module "local_roles" {
  source = "../../iam/local_role_data"
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "key_policy" {
  # Put default policies first so IAM document diff is minimized due to variation in size of user-supplied stanza keys.
  statement {
    actions   = ["kms:*"]
    effect    = "Allow"
    resources = ["*"]
    sid       = "AllowAdministrators"
    principals {
      # Intentionally not including the 'current' principal ARN that's available via local_roles; people running
      # Terraform as unexpected users or roles should explicitly add their principal to key_administrator_arns if they
      # need that access. That can be inconvenient, but mitigates the risk that a specific, unexpected principal creates
      # a KMS key at one point in time, and then later on that principal is repurposed into a use-case that should not
      # any longer be allowed to administer the key. Explicit > implicit, in other words.
      type        = "AWS"
      identifiers = sort(module.local_roles.most_privileged_users)
    }
  }
  statement {
    # Wiz's scanner role doesn't by default have permissions to see this key; permissions must be added on a per-key
    # basis for KMS, since KMS is special WRT IAM permissions. See modules/wiz/README.md for more details.
    actions   = ["kms:DescribeKey"]
    effect    = "Allow"
    resources = ["*"]
    sid       = "AllowWizToDescribeKey"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/WizAccess-Role"]
    }
  }

  dynamic "statement" {
    for_each = var.policy_stanzas
    content {
      effect    = "Allow"
      resources = ["*"]
      actions   = statement.value.actions
      sid       = statement.key
      dynamic "principals" {
        for_each = statement.value.principals
        content {
          type        = principals.key
          identifiers = principals.value
        }
      }
      dynamic "condition" {
        for_each = statement.value.conditions
        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

resource "aws_kms_key" "this" {
  description                        = var.description
  enable_key_rotation                = true
  deletion_window_in_days            = 7
  bypass_policy_lockout_safety_check = false # Don't let us create immortal/unmanageable keys.
  policy                             = data.aws_iam_policy_document.key_policy.json
  tags                               = var.tags
}

resource "aws_kms_alias" "key_alias" {
  name          = "alias/${var.alias}"
  target_key_id = aws_kms_key.this.key_id
}