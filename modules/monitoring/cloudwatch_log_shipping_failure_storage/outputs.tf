output "failed_shipments_s3_bucket_arn" {
  value = module.s3_bucket.bucket_arn
}

output "failed_shipments_cloudwatch_log_group_name" {
  value = module.log_group.cloudwatch_log_group_name
}
