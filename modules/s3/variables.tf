variable "name_prefix" {
  description = "Name prefix of the S3 bucket."
  type        = string
  nullable    = true
  # Intentionally not default=null; users who want a globally unique name should have to be very explicit about requesting one.
  validation {
    condition     = (var.name_prefix == null) != (var.globally_unique_name == null)
    error_message = "One and only one of 'name_prefix' and 'globally_unique_bucket_name' must be set."
  }
}

variable "globally_unique_name" {
  description = "GLOBALLY UNIQUE name of the S3 bucket. Must be unique across all customers of AWS (not just our accounts or regions: every AWS user in the entire world). Most cases should use 'name_prefix' instead."
  type        = string
  nullable    = true
  default     = null
}

variable "record_history" {
  description = "Whether to set bucket versioning and Object Lock on this bucket; Security Hub complains if you do not do this. If it is turned off for a bucket (e.g. for clients that don't support Object Lock headers), comment the invocation thoroughly as security scan findings will occur that need to be justified."
  type        = bool
  default     = true
}

variable "object_lock" {
  description = "Whether to enable Object Lock on the bucket"
  type        = bool
  default     = true
}


variable "empty_bucket_when_deleted" {
  description = "Whether or not to empty the bucket and delete all contained objects when it is deleted via Terraform/Terragrunt"
  type        = bool
  default     = false
}

variable "bucket_acl" {
  type     = string
  nullable = true
  default  = null # TODO consider defaulting to 'private' and updating folks who use S3?
}

variable "kms_key_arn" {
  description = "KMS Key ARN used to encrypt this bucket. Defaults to the account-wide default S3 encryption KMS key."
  type        = string
  default     = "aws/s3"
}

variable "policy_stanzas" {
  description = "Stanzas to add to the bucket policy (in addition to default rules requiring HTTPS access and administration). By default a stanza applies to all objects in the bucket; specify 'object_paths' to narrow that."
  # NB: 'sid' is omitted and will be derived from the key.
  # NB: 'resources' is omitted and will be generated internally.
  # NB: 'effect' is omitted and defaulted to 'Allow'. Permitting 'Deny' effects for S3 bucket policies risks creating
  #     immortal, unmanageable buckets that can only be removed by root or deleting the AWS account which contains them.
  #     If 'Deny' support is needed, add it here with care.
  type = map(object({
    conditions = optional(list(object({
      test     = string
      values   = list(string)
      variable = string
    })), [])
    actions      = set(string)
    principals   = map(set(string))          # E.g. "AWS" = ["arn:aws:iam:foobar"]
    object_paths = optional(set(string), []) # Paths within the bucket, e.g. ["/foo/*"]
  }))
  default = {}
}

variable "bucket_acceleration" {
  description = "Enable acceleration for the bucket"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to add to the resources"
  type        = map(string)
  default     = {}
}
