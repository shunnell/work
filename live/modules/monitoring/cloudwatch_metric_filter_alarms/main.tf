resource "aws_cloudwatch_log_metric_filter" "this" {
  for_each       = var.metric_filter_alarms
  name           = each.value.metric_filter.metric_name
  pattern        = each.value.metric_filter.pattern
  log_group_name = each.value.metric_filter.log_group_name

  metric_transformation {
    name          = each.value.metric_filter.metric_name
    namespace     = each.value.metric_filter.namespace
    value         = tostring(each.value.metric_filter.metric_transformation_value)
    default_value = each.value.metric_filter.default_value
  }
}

resource "aws_cloudwatch_metric_alarm" "this" {
  for_each = var.metric_filter_alarms

  alarm_name          = each.value.alarm.alarm_name
  alarm_description   = each.value.alarm.alarm_description
  comparison_operator = each.value.alarm.comparison_operator
  evaluation_periods  = each.value.alarm.evaluation_periods
  metric_name         = each.value.metric_filter.metric_name # Using the same metric name from the filter
  namespace           = each.value.metric_filter.namespace
  period              = each.value.alarm.period
  statistic           = each.value.alarm.statistic
  threshold           = each.value.alarm.threshold
  alarm_actions       = each.value.alarm.alarm_actions
  dimensions          = each.value.alarm.dimensions
  tags                = var.tags

  depends_on = [aws_cloudwatch_log_metric_filter.this]
}
