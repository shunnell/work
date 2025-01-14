variable "instance_arn" {
  description = "The Amazon Resource Name (ARN) of the SSO Instance"
  type        = string
}

variable "permission_set_arn" {
  description = "The ARN of the Permission Set"
  type        = string
}

variable "inline_policy" {
  description = "Inline policy JSON document to attach to the permission set"
  type        = string
  nullable    = true
}
