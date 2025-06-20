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

variable "num_cache_clusters" {
  description = "Number of cache clusters"
  type        = number
  default     = 2
}

variable "tags" {
  description = "Tags to add to the cache"
  type        = map(string)
  default     = {}
}
