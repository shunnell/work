variable "log_group_arns" {
  description = "List of CloudWatch log group ARNs to ship to the Firehose specified in destination_arn. ARNs may optionally end with ':*'; this does not affect internal operations. The ':*' suffix does not imply that this variable accepts log group patterns, however; only single ARNs may be specified."
  type        = list(string)
  validation {
    # Many things that retrieve the ARNs of CWLGs retrieve "invalid" ARNs ending in :*. We accept either kind for ease
    # of use, and normalize internally.
    condition     = alltrue([for v in var.log_group_arns : provider::aws::arn_parse(trimsuffix(v, ":*")) != null])
    error_message = "Each element must be an ARN, optionally ending with ':*'"
  }
}

variable "destination_arn" {
  description = "ARN of the CloudWatch destination resource that will ship selected logs. Can be an account-local Lambda or Firehose or Kinesis stream, or a local or remote CloudWatch log destination."
  type        = string
  validation {
    condition     = provider::aws::arn_parse(var.destination_arn) != null
    error_message = "Must be an ARN"
  }
}

variable "tags" {
  description = "Key-value map of tags for the permission set"
  type        = map(string)
  default     = {}
}
