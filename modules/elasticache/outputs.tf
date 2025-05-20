output "arn" {
  description = "ARN of the created ElastiCache Replication Group."
  value       = aws_elasticache_replication_group.this.arn
}

output "engine_version_actual" {
  description = "Because ElastiCache pulls the latest minor or patch for a version, this attribute returns the running version of the cache engine."
  value       = aws_elasticache_replication_group.this.engine_version_actual
}

output "configuration_endpoint_address" {
  description = "Address of the replication group configuration endpoint"
  value       = aws_elasticache_replication_group.this.configuration_endpoint_address
}

output "member_clusters" {
  description = "Identifiers of all the nodes that are part of this replication group."
  value       = aws_elasticache_replication_group.this.member_clusters
}

output "id" {
  description = "ID of the ElastiCache Replication Group."
  value       = aws_elasticache_replication_group.this.id
}

output "secret_arn" {
  description = "ARN of the secret containing the auth token"
  value       = module.cache_auth_token.secret_arn
}

output "secret_id" {
  description = "ID of the secret containing the auth token"
  value       = module.cache_auth_token.secret_id
}

output "security_group_id" {
  description = "ID of the security group."
  value       = module.security_group.id
}
