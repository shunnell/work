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

variable "account_name" {
  description = "Name of the account"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the resources"
  type        = map(string)
  default     = {}
}
