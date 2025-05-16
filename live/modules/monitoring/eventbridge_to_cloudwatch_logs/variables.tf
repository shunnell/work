variable "aws_services" {
  description = "List of names AWS service for which to capture EventBridge events in CloudWatch logs, not starting with 'aws.' Example: ['guardduty', 'codeartifact']"
  type        = set(string)
  validation {
    condition     = length(var.aws_services) > 0
    error_message = "Must have at least one element"
  }
  validation {
    condition     = alltrue([for s in var.aws_services : !startswith(s, "aws.")])
    error_message = "Service names should not start with 'aws.'; remove that prefix and pass only the service name."
  }
}

variable "log_retention_days" {
  description = "How long to retain EventBridge-captured logs in the local account. Defaulted to 1 (the minimum) since most EventBridge logs are immediately shipped to Splunk."
  type        = number
  default     = 1
  validation {
    condition     = var.log_retention_days > 0
    error_message = "Must be a positive number"
  }
}

variable "tags" {
  description = "Key-value map of tags for the permission set"
  type        = map(string)
  default     = {}
}
