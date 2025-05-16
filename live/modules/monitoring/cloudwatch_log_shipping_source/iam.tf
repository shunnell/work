resource "aws_iam_policy" "cwlg_subscription_write_allowlist" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "logs:PutLogEvents"
        Resource = [for v in var.log_group_arns : "${trimsuffix(v, ":*")}:*"]
      }
    ]
  })
  tags = var.tags
}

module "cwlg_subscription_filter_role" {
  source                 = "../../iam/role"
  role_name_prefix       = "CloudWatchToFirehoseSubscription"
  assume_role_principals = ["logs.amazonaws.com"]
  policy_arns            = [aws_iam_policy.cwlg_subscription_write_allowlist.arn]
  tags                   = var.tags
}
