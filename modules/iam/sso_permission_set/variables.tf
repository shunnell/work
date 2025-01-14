variable "permission_set_name" {
  description = "The name of the permission set"
  type        = string
}

variable "description" {
  description = "The description of the permission set"
  type        = string
  default     = null
}

variable "instance_arn" {
  description = "The Amazon Resource Name (ARN) of the SSO Instance"
  type        = string
}

variable "session_duration" {
  description = "The length of time that the application user sessions are valid for"
  type        = string
  default     = "PT1H"
}

variable "managed_policy_arns" {
  description = "List of managed policy ARNs to attach to the permission set"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Key-value map of tags for the permission set"
  type        = map(string)
  default     = {}
}
