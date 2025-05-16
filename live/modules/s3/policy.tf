# We use 'local_role_data' directly here rather than requiring it be passed as an input, since it is VERY VERY BAD
# if an accidental input mistake results in a bucket with a policy that doesn't permit anyone to manage it; that bucket
# can't be deleted or changed by anyone, it lasts forever. Avoiding that risk is worth breaking separation of concerns
# a bit and fetching 'local_role_data' multiple times.
module "local_roles" {
  source = "../iam/local_role_data"
}

locals {
  bucket_resources = [
    aws_s3_bucket.this.arn,
    "${aws_s3_bucket.this.arn}/*"
  ]
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid       = "AllowBucketAdministratorsByArn"
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = local.bucket_resources
    principals {
      type        = "AWS"
      identifiers = sort(module.local_roles.most_privileged_users)
    }
  }
  statement { # Deny HTTP requests to satisfy a security control
    sid       = "DenyNonSecureTransport"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = local.bucket_resources
    principals {
      identifiers = ["*"]
      type        = "*"
    }
    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }
  }
  dynamic "statement" {
    for_each = var.policy_stanzas
    content {
      sid       = statement.key
      effect    = "Allow"
      actions   = statement.value.actions
      resources = length(statement.value.object_paths) == 0 ? local.bucket_resources : [for p in statement.value.object_paths : "${aws_s3_bucket.this.arn}/${trimprefix(p)}"]
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

resource "aws_s3_bucket_policy" "main_policy" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}
