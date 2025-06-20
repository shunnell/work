locals {
  wiz_role_name = "WizAccess-Role" # Recommended role name per Wiz docs
  aws_builtin_policies = [
    "AmazonBedrockReadOnly",
    "job-function/ViewOnlyAccess",
    "SecurityAudit",
    "AWSLambda_ReadOnlyAccess",
  ]
}

data "aws_iam_policy_document" "wiz_role_trust_policy" {
  statement {
    effect = "Allow"
    principals {
      identifiers = var.wiz_external_role_arns
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
  tags              = var.tags
  policy_arns = flatten([
    aws_iam_policy.wiz_full_policy_0.arn,
    aws_iam_policy.wiz_full_policy_1.arn,
    aws_iam_policy.wiz_full_policy_2.arn,
    [for policy in local.aws_builtin_policies : "arn:${data.aws_partition.current.partition}:iam::aws:policy/${policy}"],
    aws_iam_policy.wiz_cloud_cost_policy[*].arn,
    aws_iam_policy.wiz_defend_policy[*].arn,
    aws_iam_policy.wiz_lightsail_policy[*].arn,
    aws_iam_policy.wiz_policy_data[*].arn,
    aws_iam_policy.wiz_policy_eks[*].arn,
    aws_iam_policy.wiz_terraform_scanning_policy[*].arn
  ])
}
