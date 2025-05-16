variable "shared_resource_types" {
  description = "List of AWS OAM-supported resource types (e.g. AWS::Logs::LogGroup) to share with the sink"
  type        = list(string)
  validation {
    condition     = (var.sink_id == null) == (length(var.shared_resource_types) == 0)
    error_message = "If sink_id is null shared_resource_types must be empty."
  }
}

variable "sink_id" {
  description = "ARN of the CloudWatch OAM::Sink object to share data with (aka the receiver)"
  type        = string
  nullable    = true
  validation {
    condition     = var.sink_id == null || can(provider::aws::arn_parse(var.sink_id))
    error_message = "Must be an ARN or null"
  }
}

variable "tags" {
  description = "Key-value map of tags for the permission set"
  type        = map(string)
  default     = {}
}
