# Ref: https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_principal.html
data "aws_iam_policy_document" "assume_role_policy" {
  source_policy_documents = [var.trust_policy_json]
  dynamic "statement" {
    for_each = var.assume_role_principals
    content {
      actions = ["sts:AssumeRole"]
      principals {
        type        = can(regex(local.service_principal_regex, statement.key)) ? "Service" : "AWS"
        identifiers = [statement.key]
      }
      dynamic "condition" {
        for_each = var.condition_trust_policy
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

resource "aws_iam_role" "this" {
  name                 = var.role_name
  path                 = var.role_path
  permissions_boundary = var.permissions_boundary_policy_arn
  name_prefix          = var.role_name_prefix
  assume_role_policy   = data.aws_iam_policy_document.assume_role_policy.json
  tags                 = var.tags
  description          = var.description
  lifecycle {
    precondition {
      condition     = (var.role_name == null) != (var.role_name_prefix == null)
      error_message = "Only one of role_name and role_name_prefix must be set"
    }
  }
}
