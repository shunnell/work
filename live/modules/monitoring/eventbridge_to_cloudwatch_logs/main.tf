module "cwlg" {
  source         = "../cloudwatch_log_group"
  for_each       = var.aws_services
  log_group_name = "/aws/events/cloudcity-${each.key}"
  retention_days = var.log_retention_days
  tags           = var.tags
}

resource "aws_cloudwatch_event_rule" "rule" {
  for_each = var.aws_services
  event_pattern = jsonencode(
    {
      "source" : [
        "aws.${each.key}"
      ]
    }
  )
  tags = var.tags
}

resource "aws_cloudwatch_event_target" "target" {
  for_each = var.aws_services
  rule     = aws_cloudwatch_event_rule.rule[each.key].name
  arn      = module.cwlg[each.key].cloudwatch_log_group_arn
}
