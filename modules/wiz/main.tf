locals {
  wiz_user_name     = "WizAccess-User"
  wiz_role_name     = "WizAccess-Role"
  user_arn          = "arn:aws:iam::${var.master_account_id}:user/${local.wiz_user_name}"
  is_master_account = data.aws_caller_identity.current.account_id == var.master_account_id
}

resource "aws_iam_user" "wiz_user" {
  count = local.is_master_account ? 1 : 0
  name  = local.wiz_user_name
  lifecycle {
    postcondition {
      condition     = self.arn == local.user_arn
      error_message = "Expected IAM user ARN to be ${local.user_arn}"
    }
  }
}

data "aws_iam_policy_document" "wiz_user_trust_policy" {
  statement {
    effect    = "Allow"
    resources = ["arn:aws:iam::*:role/${module.wiz_role.role_name}"]
    actions   = ["sts:AssumeRole"]
  }
}

resource "aws_iam_user_policy" "wiz_user_trust_policy" {
  count  = local.is_master_account ? 1 : 0
  name   = "WizUserPolicy"
  policy = data.aws_iam_policy_document.wiz_user_trust_policy.json
  user   = local.wiz_user_name
}

data "aws_iam_policy_document" "wiz_role_trust_policy" {
  statement {
    effect = "Allow"
    principals {
      identifiers = setunion([local.is_master_account ? aws_iam_user.wiz_user[0].arn : local.user_arn], var.assume_role_principals)
      type        = "AWS"
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "StringEquals"
      values   = [var.external_id]
      variable = "sts:ExternalId"
    }
  }
}

module "wiz_role" {
  source            = "../iam/role"
  role_name         = local.wiz_role_name
  trust_policy_json = data.aws_iam_policy_document.wiz_role_trust_policy.json
  tags = merge(
    var.tags,
    jsondecode(file("${path.module}/timestamp.json"))
  )
  policy_arns = flatten([
    aws_iam_policy.wiz_full_policy_0.arn,
    aws_iam_policy.wiz_full_policy_1.arn,
    aws_iam_policy.wiz_full_policy_2.arn,
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/job-function/ViewOnlyAccess",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/SecurityAudit",
    aws_iam_policy.wiz_cloud_cost_policy[*].arn,
    aws_iam_policy.wiz_defend_policy[*].arn,
    aws_iam_policy.wiz_lightsail_policy[*].arn,
    aws_iam_policy.wiz_policy_data[*].arn,
    aws_iam_policy.wiz_policy_eks[*].arn,
    aws_iam_policy.wiz_terraform_scanning_policy[*].arn
  ])
}
