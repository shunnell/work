variable "db_cluster_identifier" {
  description = "Unique identifier for the DB instance"
  type        = string
}

variable "cluster_db_name" {
  description = "Name for an automatically created database on cluster creation"
  type        = string
}

variable "master_username" {
  description = "Username for the master DB user. Required unless `snapshot_identifier` or `replication_source_identifier` is provided or unless a `global_cluster_identifier` is provided when the cluster is the secondary cluster of a global database"
  type        = string
}

variable "manage_master_user_password_rotation" {
  description = <<-DESC
    Whether to manage the master user password rotation.
    By default, false on creation, rotation is managed by RDS.
    There is not currently a way to disable this on initial creation even when set to false.
    Setting this value to false after previously having been set to true will disable automatic rotation.
    Create with 'true', then re-apply with 'false' if password rotation should not be enabled.
    See: https://github.com/terraform-aws-modules/terraform-aws-rds-aurora/blob/master/main.tf#L465C1-L470C72
    DESC
  type        = bool
  default     = true
}

variable "master_user_password_rotation_automatically_after_days" {
  description = "Automatically rotate password after number of days"
  type        = number
  default     = 365
}

variable "vpc_id" {
  description = "ID of the VPC this will belong to"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "You must provide at least 2 subnet IDs in different AZs for RDS/Aurora multi-AZ setup"
  }
}

variable "engine" {
  description = "Database engine"
  type        = string
  default     = "aurora-postgresql"
  validation {
    condition     = strcontains(var.engine, "aurora")
    error_message = "Database engine must be of an 'aurora' type"
  }
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "16.6"
}

variable "port" {
  description = "The port on which the DB accepts connections"
  type        = string
  default     = "5432"
}

variable "inbound_security_group_ids" {
  description = "Security Group IDs to allow inbound traffic from"
  type        = map(string)
  default     = {}
}

variable "min_capacity" {
  description = "Minimum number of ACUs - must be multiple of 0.5"
  type        = number
  default     = 0.5
}

variable "max_capacity" {
  description = "Maximum number of ACUs - must be multiple of 0.5"
  type        = number
  default     = 10.0
}

variable "seconds_until_auto_pause" {
  description = "Time, in seconds, before an Aurora DB cluster in provisioned DB engine mode is paused. Valid values are 300 through 86400"
  type        = number
  nullable    = true
  default     = null
}

variable "instance_names" {
  description = "List of instance names. Represents number of instances"
  type        = list(string)
  default     = ["one"]
  validation {
    condition     = length(var.instance_names) >= 1
    error_message = "You must provide at least 1 instance name"
  }
}

variable "create_timeout" {
  description = "Create timeout configuration for the cluster"
  type        = string
  default     = "15m"
}

variable "delete_timeout" {
  description = "Delete timeout configuration for the cluster"
  type        = string
  default     = "15m"
}

variable "update_timeout" {
  description = "Update timeout configuration for the cluster"
  type        = string
  default     = "15m"
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Set of log types to export to cloudwatch. If omitted, no logs will be exported"
  type        = list(string)
  default     = ["postgresql", "instance", "iam-db-auth-error"]
}

variable "security_group_rules" {
  description = "Security group rules to apply to the RDS instance"
  type        = any
  default     = {}
}

variable "apply_immediately" {
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags for the RDS instance"
  type        = map(string)
  default     = {}
}
