data "aws_iam_policy_document" "lambda_security_restrictions" {
  statement {
    sid    = "DenyLambdaFunctionURLs"
    effect = "Deny"
    actions = [
      "lambda:CreateFunctionUrlConfig",
      "lambda:UpdateFunctionUrlConfig"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "RequireVPCForLambda"
    effect = "Deny"
    actions = [
      "lambda:CreateFunction",
      "lambda:UpdateFunctionConfiguration"
    ]
    resources = ["*"]

    condition {
      test     = "Null"
      variable = "lambda:VpcIds"
      values   = ["true"]
    }
  }
}

resource "aws_organizations_policy" "lambda_security_restrictions" {
  name        = "LambdaSecurityRestrictions"
  description = "No Function URLs and VPC required"
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.lambda_security_restrictions.json
  tags        = var.lambda_security_policy_tags
}

# Attach Lambda SCP to Root
resource "aws_organizations_policy_attachment" "attach_lambda_policy_to_root" {
  policy_id = aws_organizations_policy.lambda_security_restrictions.id
  target_id = var.organizational_unit
}