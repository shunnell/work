variable "instance_arn" {
  description = "The Amazon Resource Name (ARN) of the SSO Instance"
  type        = string
}

variable "identity_store_id" {
  description = "The ID of the identity store associated with SSO instance"
  type        = string
}

variable "group_display_name" {
  description = "The name of the group"
  type        = string
}

variable "account_to_permission_set_map" {
  description = "Mapping of AWS Account ID (key) to permission_set_arn (value)."
  type        = map(string)
}