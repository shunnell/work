# TODO DRY this code up with code to manage the Sandbox_Dev role once that's moved into modules.

module "iam_fragments" {
  source = "../../iam/fragments"
}

data "aws_iam_policy_document" "sandbox_boundary" {
  source_policy_documents = [module.iam_fragments.kms_decrypt_restrictions.json]
  statement {
    sid    = "DenyIAMModifications"
    effect = "Deny"
    actions = [
      "iam:Activate*",
      "iam:Add*",
      "iam:Attach*",
      "iam:Create*",
      "iam:Deactivate*",
      "iam:Delete*",
      "iam:Detach*",
      "iam:Disable*",
      "iam:Put*",
      "iam:Remove*",
      "iam:Reset*",
      "iam:Set*",
      "iam:Tag*",
      "iam:Untag*",
      "iam:Update*",
      "iam:Upload*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowOnlyKnownServices"
    effect = "Allow"
    actions = [
      "apigateway:*",
      "cloudfront:*",
      "cloudfront-keyvaluestore:*",
      "cloudwatch:*",
      "cognito-idp:*",
      "databrew:*",
      "dms:*",
      "dynamodb:*",
      "ebs:*",
      "ec2:*",
      "ecr:*",
      "eks:AccessKubernetesApi",
      "eks:List*",
      "eks:Describe*",
      "elasticache:*",
      "elasticloadbalancing:*",
      "emr-containers:*",
      "emr-serverless:*",
      "events:*",
      "firehose:*",
      "glue:*",
      "grafana:*",
      "kafka:*",
      "kafkaconnect:*",
      "kinesis:*",
      "kms:*",
      "lakeformation:*",
      "lambda:*",
      "logs:*",
      "opsworks:*",
      "rds:*",
      "rds-db:*", # Used to allow IAM to use PAM/IAM-linked auth with RDS databases from tenant IAM roles
      "redshift:*",
      "route53:*",
      "s3:*",
      "secretsmanager:*",
      "sqs:*",
      "ssm:*",
      "sts:GetServiceBearerToken",
      "waf:*"
    ]
    resources = ["*"]
  }
}

module "sandbox_permissions_boundary" {
  source = "../../iam/policy"

  policy_name        = "SandboxPermissionsBoundary"
  policy_path        = "/platform/"
  policy_description = "PermissionsBoundary for IAM roles created by Sandbox_Dev. To prevent priviledge escalation, this role cannot perform any IAM modifications. It's also limited to using known services."
  policy_json        = data.aws_iam_policy_document.sandbox_boundary.json
  tags               = var.tags
}

data "aws_caller_identity" "current" {}

# Create a role with no access and the above permissions boundary. This serves two purposes:
# 1. It can be useful in rare circumstances when testing/validating IAM actions that can fail (a role with no access
#    should fail everything).
# 2. Some Security Hub compliance scans detect "dangerous" policies that permit too much ... unless those policies are
#    only used as permissions boundaries (e.g. KMS.1 scan). If a policy is unattached/unused, those scans generate
#    alerts, but if a policy is attached and only as a permissions boundary, it is silenced.
module "dummy_sandbox_bounded_role" {
  source    = "../../iam/role"
  role_name = "NoAccess"
  # Anyone can assume it, they just can't do anything once they do:
  assume_role_principals          = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
  permissions_boundary_policy_arn = module.sandbox_permissions_boundary.policy_arn
}