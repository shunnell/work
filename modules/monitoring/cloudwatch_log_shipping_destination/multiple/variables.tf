variable "destination_names" {
  type        = set(string)
  description = "Vector of destination names, which can be any string"
}

variable "failed_shipments_s3_bucket_arn" {
  type        = string
  description = "See variable of the same name in cloudwatch_log_shipping_destination"
}

variable "failed_shipments_cloudwatch_log_group_name" {
  type        = string
  description = "See variable of the same name in cloudwatch_log_shipping_destination"
}

variable "log_sender_aws_organization_path" {
  type        = string
  description = "See variable of the same name in cloudwatch_log_shipping_destination"
}

variable "tags" {
  description = "Key-value map of tags for the resource"
  type        = map(string)
  default     = {}
}

variable "account_list_mapping" {
  description = "pairs of account_ids and account names to identify tenants"
  type        = map(string)
  default     = {}
}

variable "vpc_subnet_ids" {
  description = "Subnet IDs"
  type        = list(string)
  validation {
    condition     = length(var.vpc_subnet_ids) > 0
    error_message = "At least 1 subnet ID must be passed"
  }
  validation {
    condition     = alltrue([for s in var.vpc_subnet_ids : startswith(s, "subnet-")])
    error_message = "All subnet IDs must start with 'subnet-'"
  }
}

