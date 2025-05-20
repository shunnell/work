variable "destination_name" {
  description = "Name of this destination (e.g. 'CloudWatch' or 'GuardDuty'). Destinations are heavy-weight and should be shared where appropriate in order to maximize shipping efficiency and reduce infrastructure complexity."
  type        = string
  # TODO make sure it fits in the lambda function name (64)
  validation {
    condition     = can(regex("^(?:\\w|[-_/])+$", var.destination_name))
    error_message = "May only contain letters, numbers, slashes, or spaces"
  }
}

variable "log_sourcetype" {
  /*
      https://splunk.github.io/splunk-add-on-for-amazon-web-services/DataTypes/#push-based-amazon-kinesis-firehose-data-collection-sourcetypes
  */
  description = "Type of cloudwatch log (e.g 'cloudwatch', 'cloudtrail') to help label the sourcetype appropriately"
  type        = string
  default     = "aws:cloudwatch" # identify from logGroup in cloudwatch logs payload
}

variable "failed_shipments_s3_bucket_arn" {
  description = "ARN of a bucket which will store failed log shipments. Within this bucket, failed shipments will be stored under akey corresponding to destination_name."
  type        = string
  # TODO arn
}

variable "failed_shipments_cloudwatch_log_group_name" {
  description = "Name of a CloudWatch log group to which log shipment failure error information will be written by Firehose (transformation Lambda invocation failures will be written to a separate log group)"
  type        = string # TODO no ARN, no trailing colon?
}

variable "log_sender_aws_organization_path" {
  description = "ID of the AWS Organization or subpath within an Organization that should be permitted to send logs via this module's Firehose from other AWS accounts"
  type        = string
}

variable "splunk_uri" {
  description = "HTTP/S URI of the Splunk HEC destination to be used"
  type        = string
  default     = "https://casi.state.gov:8088"
}

variable "splunk_hec_token" {
  description = "String token to be used when identifying this log stream to Splunk"
  type        = string
  # This value is not currently secret or very sensitive. It has been shared/circulated in IMs and emails. This token
  # identifies BESPIN AWS logs to Splunk in a test/interim capacity. In the future, we will very likely switch to using
  # one or more tokens which *are* secret, for long-term, secured logs, stored in SecretsManager. Traffic between
  # BESPIN and Splunk is also encrypted using HTTPS by default, and will be further encrypted with appropriate
  # cert-bsased authentication in the future, but that infrastructure has not been provided by the Splunk team yet.
  default = "419b5b09-db88-48a0-bd1b-21ab330c0b0d"
}

variable "splunk_acknowledgement_timeout" {
  description = "Number of seconds to wait for Splunk to acknowledge a log shipment before considering it failed (assuming that the splunk HEC ingester is configured to send acknowledgements)"
  type        = number
  default     = 180 # The shortest allowed ack timeout value from Splunk, per their docs.
}


variable "shipment_buffering_time" {
  description = "How many seconds to buffer logs in BESPIN before shipping them"
  type        = number
  default     = 60
  validation {
    condition     = var.shipment_buffering_time >= 60 && var.shipment_buffering_time <= 900
    error_message = "Must be between 60-900 (AWS enforced)"
  }
}

variable "shipment_buffering_size" {
  description = "How many megabytes of logs to buffer before sending a shipment to Splunk"
  type        = number
  default     = 1 # Aws default = 5
  validation {
    condition     = var.shipment_buffering_size >= 1 && var.shipment_buffering_size <= 128
    error_message = "Must be between 1-128 (AWS enforced)"

  }
}

variable "shipment_retry_duration" {
  description = "How many seconds to wait before retrying a failed shipment"
  type        = number
  default     = 10
}

variable "tags" {
  description = "Key-value map of tags for the resource"
  type        = map(string)
  default     = {}
}
