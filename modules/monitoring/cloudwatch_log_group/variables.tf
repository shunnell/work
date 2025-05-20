variable "log_group_name" {
  description = "Name of the CloudWatch Log Group"
  type        = string
}

variable "retention_days" {
  description = "Number of days to retain log events"
  type        = number
  default     = 90
}

variable "kms_key_arn" {
  description = "ARN of KMS key for encryption (optional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
