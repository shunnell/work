variable "name_prefix" {
  description = "Prefix used for naming and ALB lookup."
  type        = string
}

variable "managed_rule_id" {
  description = "ID of the WAF Classic managed rule group."
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
