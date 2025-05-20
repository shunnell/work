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

variable "vpc_id" {
  description = "ID of the VPC this will belong to"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "you must provide at least 2 subnet IDs in different AZs for  RDS/Aurora multi-AZ setup."
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
  description = "Minimum number of read replicas permitted when autoscaling is enabled"
  type        = number
  default     = 0
}

variable "max_capacity" {
  description = "Maximum number of read replicas permitted when autoscaling is enabled"
  type        = number
  default     = 10
}

variable "seconds_until_auto_pause" {
  type    = number
  default = 3600
}

variable "instance_names" {
  description = "List of instance names. Represents number of instances"
  type        = list(string)
  default     = ["one"]
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
  description = "Set of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: `audit`, `error`, `general`, `slowquery`, `postgresql`"
  type        = list(string)
  default     = ["postgresql", "instance", "iam-db-auth-error"]
}

variable "tags" {
  description = "Tags for the RDS instance"
  type        = map(string)
  default     = {}
}
