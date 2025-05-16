output "cloudwatch_log_group_arns" {
  description = "ARNs of the cloudwatch log groups that capture each AWS service. Map of service (from aws_services) to ARN."
  value       = { for k in var.aws_services : k => module.cwlg[k].cloudwatch_log_group_arn }
}