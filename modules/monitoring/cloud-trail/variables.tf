
variable "cloudtrail_name" {
  description = "Name of the CloudTrail"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for storing CloudTrail logs"
  type        = string
}

variable "is_multi_region_trail" {
  description = "Whether the trail is multi-region"
  type        = bool
}

variable "cloud_watch_logs_group_arn" {
  description = "ARN of the CloudWatch Logs group"
  type        = string
}

variable "cloud_watch_logs_role_arn" {
  description = "ARN of the IAM role for CloudWatch Logs"
  type        = string
}

variable "tags" {
  description = "Tags for the CloudTrail"
  type        = map(string)
  default     = {}
}