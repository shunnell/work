variable "db_instance_identifier" {
  description = "Unique identifier for the DB instance"
  type        = string
}

variable "allocated_storage" {
  description = "Allocated storage size in GiB"
  type        = number
}

variable "engine" {
  description = "Database engine"
  type        = string
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
}

variable "instance_class" {
  description = "Instance class"
  type        = string
}

variable "username" {
  description = "Database username"
  type        = string
}

variable "password" {
  description = "Database password"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = true
}

variable "vpc_security_group_ids" {
  description = "VPC security group IDs"
  type        = list(string)
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
}

variable "storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
}

variable "monitoring_interval" {
  description = "Monitoring interval in seconds"
  type        = number
}

variable "monitoring_role_arn" {
  description = "ARN of the IAM role for monitoring"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "tags" {
  description = "Tags for the RDS instance"
  type        = map(string)
  default     = {}
}