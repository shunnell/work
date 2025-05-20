# We don't do validation here since these are all passed to modules which are coded sufficiently defensively.
# There's no need to duplicate that code.
variable "eventbridge_service_name_to_destination_arn" {
  description = "Map of eventbridge service names (without 'aws.' prefix) to log shipment Cloudwatch::Logs::Destination ARNs"
  type        = map(string)
}

variable "oam_sink_id" {
  description = "ARN of the CloudWatch OAM::Sink object to share data with (aka the receiver)"
  type        = string
  nullable    = true
}

variable "oam_shared_resource_types" {
  description = "List of AWS OAM-supported resource types (e.g. AWS::Logs::LogGroup) to share with the sink"
  type        = list(string)
  default     = ["AWS::Logs::LogGroup", "AWS::CloudWatch::Metric"]
}

variable "tags" {
  description = "Key-value map of tags for the permission set"
  type        = map(string)
  default     = {}
}
