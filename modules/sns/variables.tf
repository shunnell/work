variable "topic_name" {
  description = "Name of the SNS topic"
  type        = string
}

variable "kms_key_id" {
  description = "KMS key ID for topic encryption"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the SNS topic"
  type        = map(string)
  default     = {}
}

variable "delivery_policy" {
  description = "SNS delivery policy"
  type        = string
  default     = null
}

variable "topic_policy" {
  description = "SNS topic policy"
  type        = string
  default     = null
}

variable "subscriptions" {
  description = "List of subscription configurations"
  type = list(object({
    protocol             = string
    endpoint             = string
    filter_policy        = optional(string)
    raw_message_delivery = optional(bool, false)
  }))
  default = []
}
