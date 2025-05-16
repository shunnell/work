variable "name" {
  description = "Name of the cache"
  type        = string
}

variable "description" {
  description = "User-created description for the replication group. Must not be empty."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC this will be in"
  type        = string
}

variable "subnet_ids" {
  description = "List of VPC Subnet IDs for the cache subnet group"
  type        = set(string)
}

variable "logs_destination_arn" {
  description = "Destination ARN for CloudWatch logs"
  type        = string
}

variable "security_group_rules" {
  description = "Refer to 'network/security_group' for input details"
  type        = map(any)
  default     = {}
}

variable "engine" {
  description = "The cache engine (redis, valkey, memcached)"
  type        = string
  default     = "redis"
}

variable "snapshot_retention_limit" {
  description = "Maximum number of snapshots to retain"
  type        = number
  default     = 1
}

variable "node_type" {
  description = "The instance class used."
  type        = string
  default     = "cache.m7g.xlarge"
}

variable "num_node_groups" {
  description = "Number of node groups (shards) for this Redis replication group. Changing this number will trigger a resizing operation before other settings modifications."
  type        = number
  default     = 1
}

variable "replicas_per_node_group" {
  description = "Number of replica nodes in each node group. Changing this number will trigger a resizing operation before other settings modifications. Valid values are 0 to 5."
  type        = number
  default     = 1
}

variable "tags" {
  description = "Tags to add to the cache"
  type        = map(string)
  default     = {}
}
