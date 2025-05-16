output "log_group_arns" {
  description = "ARNs of the cloudwatch log groups that capture each AWS service from EventBridge. Map of service name to ARN."
  value       = module.eventbridge_to_cloudwatch.cloudwatch_log_group_arns
}
