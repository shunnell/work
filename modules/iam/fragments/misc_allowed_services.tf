data "aws_iam_policy_document" "general_services_restrictions" {
  statement {
    sid    = "DenyDisallowedAWSServices"
    effect = "Deny"
    actions = [
      "cloudshell:*", # CloudShell is not allowed for use in Cloud City
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "general_services_permissions" {
  statement {
    # TODO this list should be burned down to zero and/or appropriately conditioned for secure, platform-managed
    #   access to these services.
    sid    = "GrandfatheredServices"
    effect = "Allow"
    actions = [
      "cloudwatch:*",                    # Should be uniformly scoped to allow write only to tenant-name-prefixed resources.
      "codeartifact:Describe*",          # Should be restricted to only infra-account per-tenant codeartifact repos.
      "codeartifact:Get*",               # Should be restricted to only infra-account per-tenant codeartifact repos.
      "codeartifact:List*",              # Should be restricted to only infra-account per-tenant codeartifact repos.
      "codeartifact:ReadFromRepository", # Should be restricted to only infra-account per-tenant codeartifact repos.
      "cognito-idp:*",                   # Should probably not be administerable by tenants
      "datazone:*",                      # Governance tool that should either not be used or only should be administered by the platform.
      "ecr:*",                           # Should be locked down to only the infra account's ECR permissions, which are managed via other policies.
      "elasticloadbalancing:*",          # Should probably be locked down or removed in favor of EKS-managed load balancing infrastructure.
      "emr-containers:*",                # Alternative compute infrastructure to EKS, should probably be disabled.
      "emr-serverless:*",                # Alternative compute infrastructure to EKS, should probably be disabled.
      "mediaimport:*",                   # Probably unused and should not be used.
      "opsworks:*",                      # Probably unused and should not be used.
      "secretsmanager:*",                # Should be locked down in a per-tenant way.
      "ses:*",                           # Likely may be replaced with platform-managed email systems. Currently, OPR3 makes use of SES to send emails.
      "ssm:*",                           # Should be restricted to not allow security-sensitive actions that assessors have identified as risks.
      "waf:*",                           # Should likely be removed: is "waf" v1 (rather than wafv2, which is broadly allowed), even needed?
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AllowSupportedServices"
    effect = "Allow"
    actions = [
      "apigateway:*",
      "athena:*",
      "cloudformation:*",
      "cloudfront-keyvaluestore:*",
      "cloudfront:*",
      "databrew:*",
      "dms:*",
      "docdb-elastic:*",
      "dynamodb:*",
      "ebs:*",
      "elasticache:*",
      "events:*",
      "firehose:*",
      "geo-maps:*",
      "geo-places:*",
      "geo-routes:*",
      "geo:*",
      "glue:*",
      "grafana:*",
      "kafka:*",
      "kafkaconnect:*",
      "kinesis:*",
      "kms:*",
      "lakeformation:*",
      "lambda:*",
      "logs:*",
      "pipes:*",
      "rds-db:*", # Used to allow IAM to use PAM/IAM-linked auth with RDS databases from tenant IAM roles
      "rds:*",
      "redshift:*",
      "route53:*",
      "s3:*",
      "s3tables:*",
      "sns:*",
      "sqs:*",
      "states:*",
      "sts:GetServiceBearerToken",
      "wafv2:*",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AuditManagerAccess"
    effect = "Allow"
    actions = [
      "auditmanager:CreateAssessment",
      "auditmanager:Get*",
      "auditmanager:List*",
    ]
    resources = ["*"]
  }
}