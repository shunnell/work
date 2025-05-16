resource "aws_ses_email_identity" "ses_email" {
  count = length(var.ses_email)
  email = var.ses_email[count.index]
}

module "lambda_role" {
  source                 = "../iam/role"
  role_name              = "Access-key-audit-all-accounts"
  assume_role_principals = ["lambda.amazonaws.com"]
  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    aws_iam_policy.lambda_policy.arn,
    "arn:aws:iam::381492150796:policy/terragrunter_assume"

  ]
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy_access_key_rotation"
  description = "policy to allow lambda to manage IAM keys"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "iam:ListUsers",
          "iam:ListAccessKeys",
          "iam:GetAccessKeyLastUsed"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "ses:*"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "securityhub:GetFindings"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

data "archive_file" "transformer_lambda_script" {
  type        = "zip"
  source_file = "./multiaccounts.py"
  output_path = "./multiaccounts.zip"
}

resource "aws_lambda_function" "lambda_function" {
  function_name    = "AccessKeysRotation"
  role             = module.lambda_role.role_arn
  runtime          = "python3.12"
  timeout          = 60
  filename         = data.archive_file.transformer_lambda_script.output_path
  handler          = "multiaccounts.lambda_handler"
  source_code_hash = data.archive_file.transformer_lambda_script.output_base64sha256
  environment {
    variables = {
      "SES_SENDER_EMAIL" = join(",", aws_ses_email_identity.ses_email[*].email)
    }
  }
}

resource "aws_cloudwatch_event_rule" "event_rule" {
  name                = "RuleForAccessKeyRotation"
  schedule_expression = var.cloudwatch_schedule_exp
}

resource "aws_cloudwatch_event_target" "target" {
  rule      = aws_cloudwatch_event_rule.event_rule.name
  target_id = "AccessKeyRotation"
  arn       = aws_lambda_function.lambda_function.arn
}

resource "aws_lambda_permission" "permission" {
  statement_id  = "AllowExecutionFromLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.event_rule.arn
}
