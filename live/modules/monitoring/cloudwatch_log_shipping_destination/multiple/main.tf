module "firehose_destination" {
  source                                     = "../"
  for_each                                   = var.destination_names
  destination_name                           = each.key
  failed_shipments_s3_bucket_arn             = var.failed_shipments_s3_bucket_arn
  failed_shipments_cloudwatch_log_group_name = var.failed_shipments_cloudwatch_log_group_name
  log_sender_aws_organization_path           = var.log_sender_aws_organization_path
  tags                                       = var.tags
}
