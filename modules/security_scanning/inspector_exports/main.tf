data "aws_caller_identity" "current" {}

locals {
  policy_conditions = [
    {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    },
    {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:inspector2:*:${data.aws_caller_identity.current.account_id}:report/*"]
    },
  ]
  service_principal = { Service = ["inspector2.amazonaws.com"] }
  tags              = merge({ "purpose" = "AWS Inspector exports" }, var.tags)
}

module "exports_bucket" {
  source      = "../../s3"
  name_prefix = "cloudcity-inspector-exports"
  policy_stanzas = {
    "allow-inspector" = {
      conditions = local.policy_conditions
      principals = local.service_principal
      actions = [
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:AbortMultipartUpload",
      ],
    }
  }
  tags = local.tags
}

module "kms_key" {
  source      = "../../kms/key"
  description = "KMS key for AWS Inspector scan exports"
  alias       = "cloud-city/inspector-exports"
  policy_stanzas = {
    "Allow Amazon Inspector to use the key" = {
      principals = local.service_principal
      actions    = ["kms:Decrypt", "kms:GenerateDataKey*"]
      conditions = local.policy_conditions
    }
  }
  tags = local.tags
}
