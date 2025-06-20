output "metric_filter_ids" {
  description = "Map of metric filter names to their IDs"
  value = {
    for k, v in aws_cloudwatch_log_metric_filter.this : k => v.id
  }
}

output "metric_filter_names" {
  description = "Map of metric filter names to their actual names"
  value = {
    for k, v in aws_cloudwatch_log_metric_filter.this : k => v.name
  }
}

output "alarm_arns" {
  description = "Map of alarm names to their ARNs"
  value = {
    for k, v in module.metric_alarm : k => v.cloudwatch_metric_alarm_arn
  }
}

output "alarm_ids" {
  description = "Map of alarm names to their IDs"
  value = {
    for k, v in module.metric_alarm : k => v.cloudwatch_metric_alarm_id
  }
}
