variable "vpc_id" {
  description = "ID of the VPC where the firewall will be deployed"
  type        = string
}

variable "subnet_mappings" {
  description = "List of subnet IDs for firewall endpoints"
  type        = list(string)
}

variable "capacity" {
  description = "Capacity of the firewall"
  type        = string
  default     = "100"
}

variable "allowed_domains" {
  description = "List of allowed domains"
  type        = list(string)
  nullable    = false
}

variable "home_net_cidrs" {
  description = "List of CIDRs for the home network"
  type        = list(string)
  nullable    = false
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
