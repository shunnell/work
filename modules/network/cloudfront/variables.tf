variable "name_prefix" {
  description = "Prefix used in naming the S3 bucket and CloudFront distribution"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket to host the static website"
  type        = string
}

variable "aliases" {
  description = "Optional list of CNAMEs (custom domains) for CloudFront"
  type        = list(string)
  default     = []
}

variable "waf_web_acl_id" {
  description = "ID of the AWS WAF Classic (Regional) Web ACL to associate with CloudFront"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
