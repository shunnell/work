output "service_to_destination_arn" {
  value = { for k in var.destination_names : k => module.firehose_destination[k].cloudwatch_destination_arn }
}
