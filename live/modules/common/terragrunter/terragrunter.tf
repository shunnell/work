module "iam_fragments" {
  source = "../../iam/fragments"
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "terragrunter" {
  # See module source documentation for details on included documents:
  source_policy_documents = [module.iam_fragments.kms_decrypt_restrictions.json]
  statement {
    sid    = "AllowSpecifics"
    effect = "Allow"
    actions = [
      "access-analyzer:*",
      "account:Get*",
      "account:List*",
      "account:DeleteAlternateContact",
      "account:PutAlternateContact",
      "account:PutContactInformation",
      "application-autoscaling:*",
      "application-signals:*",
      "aps:*",
      "autoscaling:*",
      "athena:Get*",
      "athena:List*",
      "athena:UpdateWorkGroup",
      "athena:TagResource",
      "codeartifact:*",
      "compute-optimizer:*",
      "config:*",
      "cloudformation:*",
      "cloudfront:*",
      "cloudtrail:*",
      "cloudwatch:*",
      "dynamodb:*",
      "ec2:*",
      "ecr:*",
      "ecs:*",
      "eks:*",
      "elasticache:*",
      "elasticloadbalancing:*",
      "es:*",
      "events:*",
      "firehose:*",
      "grafana:*",
      "iam:*",
      "kms:*",
      "lambda:*",
      "logs:*",
      "macie2:*",
      "network-firewall:*",
      "oam:*",
      "rds:*",
      "route53:*",
      "s3:*",
      "secretsmanager:*",
      "servicequotas:*",
      "ses:*",
      "sns:*",
      "sqs:*",
      "ssm:*",
      "tag:*",
      "identitystore:Get*",
      "identitystore:List*",
      "identitystore:Describe*",
      "sso:*",
      # The less-scary parts of Organizations: permissions, leaving out the ability to e.g. create/destroy accounts
      # or change organization membership:
      "organizations:AttachPolicy",
      "organizations:CreatePolicy",
      "organizations:DeletePolicy",
      "organizations:UpdatePolicy",
      "organizations:TagResource",
      "organizations:UntagResource",
      "organizations:DeleteResourcePolicy",
      "organizations:EnablePolicyType",
      "organizations:DisablePolicyType",
      "organizations:Describe*",
      "organizations:List*",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "DenySpecifics"
    effect = "Deny"
    actions = [
      # Even though terragrunter is god-mode, there are certain things it shouldn't do by choice: management of static
      # IAM principals or reserved instances are not things BESPIN supports at this time, so terragrunter isn't allowed
      # to do them as a "hey, looks like you're making a mistake, please don't" guardrail for Platform staff.
      "ec2:*ReservedInstances*",
      "iam:*Group*",
      "iam:*Login*",
      "iam:*User*",
    ]
    resources = ["*"]
  }
  dynamic "statement" {
    # If we're in the infra account, set this terragrunter up to be able to assume all other terragrunters.
    for_each = data.aws_caller_identity.current.account_id == var.iac_account_id ? [1] : []
    content {
      sid     = "InfraTerragrunterAssumeAllOtherTerragrunter"
      effect  = "Allow"
      actions = ["sts:AssumeRole"]
      # This resource/condition combo amounts to: "let this role assume other roles called 'terragrunter' in the same
      # AWS organization':
      resources = ["arn:aws:iam::*:role/terragrunter"]
      condition {
        test     = "StringEquals"
        values   = ["$${aws:ResourceOrgID}"]
        variable = "aws:PrincipalOrgID"
      }
    }
  }
}

module "terragrunter_policy" {
  source             = "../../iam/policy"
  policy_name        = "terragrunter"
  policy_description = "Policy for Cloud City platform team's platform-administrator-access-only IaC management role 'terragrunter'"
  policy_json        = data.aws_iam_policy_document.terragrunter.json
  tags               = var.tags
}

module "terragrunter_role" {
  source      = "../../iam/role"
  description = "Cloud City platform team's IaC management role; can only be used by platform administrators"
  role_name   = "terragrunter"
  # Infra terragrunter can assume this role. That applies to the infra terragrunter itself, since lots of code
  # will try to do that, and adding conditions for "skip assume if already terragrunter" adds complexity.
  assume_role_principals = concat(["arn:aws:iam::${var.iac_account_id}:role/terragrunter"], var.additional_role_assumers)
  policy_arns            = concat([module.terragrunter_policy.policy_arn], var.terragrunter_role_additional_policies)
  tags                   = var.tags
}
