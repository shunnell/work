variable "group_display_name" {
  type        = string
  description = "The group display name as it appears in OKTA / Identity Center"
}

variable "identity_store_id" {
  type = string
}

variable "application_arn" {
  type        = string
  description = "The ARN of the AWS SSO Application"
}