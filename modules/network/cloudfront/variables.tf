variable "name_prefix" {
  description = "Prefix used in naming the S3 bucket and CloudFront distribution"
  type        = string
}

variable "default_root_object" {
  description = "Default object (e.g. index.html) returned when no path is specified"
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "Error document key for the S3 static website"
  type        = string
  default     = "error.html"
}

variable "aliases" {
  description = "Optional list of CNAMEs (custom domains) for CloudFront"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "logging_bucket" {
  description = "Bucket (bucket-name.s3.amazonaws.com) for CloudFront logs (empty to disable)"
  type        = string
  default     = ""
}

variable "logging_prefix" {
  description = "Prefix under the logging bucket"
  type        = string
  default     = ""
}

variable "logging_include_cookies" {
  description = "Whether to include cookies in logs"
  type        = bool
  default     = false
}
