variable "schedule_frequency" {
  description = "Backup frequency: one of daily, hourly, weekly, monthly"
  type        = string
}

variable "backup_plan_name" {
  description = "Name of the AWS Backup plan"
  type        = string
}

variable "backup_rule_name" {
  description = "Name of the backup rule"
  type        = string
}

variable "start_window" {
  description = "Start window time in minutes"
  type        = number
}

variable "completion_window" {
  description = "Completion window time in minutes"
  type        = number
}

variable "delete_after_days" {
  description = "Number of days after which to delete the recovery point"
  type        = number
}

variable "recovery_point_tags" {
  type        = map(string)
  description = "Tags to apply to AWS Backup recovery points"
}

variable "selection_tags" {
  type        = map(string)
  description = "Map of key-value pairs used for selecting resources to back up"
}

variable "existing_backup_role_name" {
  description = "Existing IAM role to use for backup selection"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to resources"
  type        = map(string)
}
