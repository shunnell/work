
resource "aws_cloudtrail" "this" {
  name                       = var.cloudtrail_name
  s3_bucket_name             = var.s3_bucket_name
  is_multi_region_trail      = var.is_multi_region_trail
  enable_log_file_validation = true

  # Optional settings
  cloud_watch_logs_group_arn = var.cloud_watch_logs_group_arn
  cloud_watch_logs_role_arn  = var.cloud_watch_logs_role_arn
  enable_logging             = true

  tags = var.tags
}
