module "oam_link" {
  source                = "../cloudwatch_sharing_source"
  sink_id               = var.oam_sink_id
  shared_resource_types = var.oam_shared_resource_types
  tags                  = var.tags
}


module "eventbridge_to_cloudwatch" {
  source       = "../eventbridge_to_cloudwatch_logs"
  aws_services = keys(var.eventbridge_service_name_to_destination_arn)
  tags         = var.tags
}


module "logs_to_firehose" {
  source          = "../cloudwatch_log_shipping_source"
  for_each        = var.eventbridge_service_name_to_destination_arn
  log_group_arns  = [module.eventbridge_to_cloudwatch.cloudwatch_log_group_arns[each.key]]
  destination_arn = each.value
  tags            = var.tags
}
