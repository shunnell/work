module "iam_fragments" {
  source = "../../iam/fragments"
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "terragrunter" {
  # See module source documentation for details on included documents:
  source_policy_documents = [module.iam_fragments.kms_decrypt_restrictions]
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
      "acm:*",
      "acm-pca:*",
      "application-autoscaling:*",
      "application-signals:*",
      "aps:*",
      "autoscaling:*",
      "athena:Get*",
      "athena:List*",
      "athena:UpdateWorkGroup",
      "athena:TagResource",
      "backup:*",
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
      "identitystore:Get*",
      "identitystore:List*",
      "identitystore:Describe*",
      "kms:*",
      "lambda:*",
      "logs:*",
      "macie2:*",
      "network-firewall:*",
      "oam:*",
      "ram:*",
      "rds:*",
      "route53:*",
      "route53profiles:*",
      "backup:*",
      "ram:*",
      "s3:*",
      "secretsmanager:*",
      "servicequotas:*",
      "ses:*",
      "sns:*",
      "sqs:*",
      "sso:*",
      "ssm:*",
      "tag:*",
      # The less-scary parts of Organizations: permissions, leaving out the ability to e.g. create/destroy accounts
      # or change organization membership:
      "organizations:AttachPolicy",
      "organizations:DetachPolicy",
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
    sid    = "DenyIamUserAndGroupManipulation"
    effect = "Deny"
    # Static IAM users and their credentials cannot be created or manipulated--not even by terragrunter--in Cloud City.
    # Forbidding this from Terragrunter provides a reminder for any third-party or erroneous code that would manage
    # static users that Cloud City is an MFA-only environment, and that static IAM principals are not allowed. More
    # details on this policy are here: https://confluence.fan.gov/display/CCPL/MFA+exemption
    resources = ["*"]
    actions = [
      "iam:ChangePassword",
      "iam:CreateAccessKey",
      "iam:UpdateAccessKey",
      "iam:CreateUser",
      "iam:UpdateUser",
      "iam:*LoginProfile*",
      "iam:*UserPolicy*",
      "iam:TagUser",
      "iam:UntagUser",
      "iam:*UserPermissionsBoundary*",
    ]
  }
  statement {
    sid    = "DenyFeaturesForbiddenInCloudCity"
    effect = "Deny"
    actions = [
      # Even though terragrunter is god-mode, there are certain things it shouldn't do by choice: management of static
      # IAM principals or reserved instances are not things BESPIN supports at this time, so terragrunter isn't allowed
      # to do them as a "hey, looks like you're making a mistake, please don't" guardrail for Platform staff.

      # No reserved instances in Cloud City at this time:
      "ec2:*ReservedInstances*",

      # No mutate/add on groups, but read and removing groups, group policies, and removing users from groups is OK:
      "iam:AttachGroupPolicy",
      "iam:DetachGroupPolicy",
      "iam:AddUserToGroup",
      "iam:CreateGroup",
      "iam:PutGroupPolicy",
      "iam:UpdateGroup",
      # No creating new SAML providers (exceptions might be added to this to support future Okta integration changes):
      "iam:CreateSAMLProvider",

      # No mutation of existing SAML providers (that could break the Okta link and lose everyone's access):
      "iam:UpdateSAMLProvider",

      # No manipulation of MFA devices:
      "iam:*MFADevice*",
      # No removal of account-wide password policies.
      "iam:DeleteAccountPasswordPolicy",
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
  condition_trust_policy = var.condition_trust_policy
  tags                   = var.tags
}
