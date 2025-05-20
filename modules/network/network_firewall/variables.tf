variable "vpc_id" {
  description = "ID of the VPC where the firewall will be deployed"
  type        = string
}

variable "subnet_mappings" {
  description = "List of subnet IDs for firewall endpoints"
  type        = list(string)
}

variable "rule_group_arns" {
  description = "List of ARNs for the rule groups"
  type        = list(string)
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  nullable    = false
}

variable "alert_log_group_name" {
  description = "Name of the alert log group"
  type        = string
}

variable "flow_log_group_name" {
  description = "Name of the flow log group"
  type        = string
}

variable "tls_log_group_name" {
  description = "Name of the TLS log group"
  type        = string
}

variable "tags" {
  description = "Key-value map of tags for the permission set"
  type        = map(string)
  default     = {}
}
