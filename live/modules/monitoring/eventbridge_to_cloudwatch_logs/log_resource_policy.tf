# We make one compound policy for all log-shipping types, since AWS has a hard 10-policies-per-account-per-region limit
# that otherwise causes actions on the policy to time out.
data "aws_iam_policy_document" "policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream"
    ]

    resources = [for cwlg in module.cwlg : "${cwlg.cloudwatch_log_group_arn}:*"]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "delivery.logs.amazonaws.com"
      ]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents"
    ]
    # Not the same as the above: note the double star
    resources = [for cwlg in module.cwlg : "${cwlg.cloudwatch_log_group_arn}:*:*"]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "delivery.logs.amazonaws.com"
      ]
    }

    condition {
      test = "ArnEquals"
      # Can't use a splat expression because it's a for_each:
      values   = [for rule in aws_cloudwatch_event_rule.rule : rule.arn]
      variable = "aws:SourceArn"
    }
  }
}

# There should not be many of these per AWS account since there's a hard limit of 10 of them.
# The hardcoded name below imposes the requirement that this module can only be instantiated once per account, which
# is good/desirable. Instantiating it multiple times should not be done; rather, one instantiation with multiple
# aws_services specified should be done instead.
resource "aws_cloudwatch_log_resource_policy" "cwlg_policy" {
  policy_document = data.aws_iam_policy_document.policy.json
  policy_name     = "cloud-city-eventbridge-log-publishing-policy"
}
