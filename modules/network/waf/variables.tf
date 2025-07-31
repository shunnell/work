variable "name_prefix" {
  description = "Prefix used for naming and ALB lookup."
  type        = string
}

variable "managed_rule_id" {
  description = "ID of the AWS-managed rule group. If provided, this will be used instead of the name."
  type        = string
  default     = ""
}

variable "managed_rule_name" {
  description = "Name of the AWS-managed rule group"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "resource_arn" {
  description = "Resource ARN to associate with this Web ACL."
  type        = string
}
