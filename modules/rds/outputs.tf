################################################################################
# RDS Aurora Module - Serverless V2
################################################################################

# aws_db_subnet_group
output "aurora_serverless_v2_db_subnet_group_name" {
  description = "The db subnet group name"
  value       = module.aurora_serverless_v2.db_subnet_group_name
}

# aws_rds_cluster
output "aurora_serverless_v2_cluster_arn" {
  description = "Amazon Resource Name (ARN) of cluster"
  value       = module.aurora_serverless_v2.cluster_arn
}

output "aurora_serverless_v2_cluster_id" {
  description = "The RDS Cluster Identifier"
  value       = module.aurora_serverless_v2.cluster_id
}

output "aurora_serverless_v2_cluster_resource_id" {
  description = "The RDS Cluster Resource ID"
  value       = module.aurora_serverless_v2.cluster_resource_id
}

output "aurora_serverless_v2_cluster_members" {
  description = "List of RDS Instances that are a part of this cluster"
  value       = module.aurora_serverless_v2.cluster_members
}

output "aurora_serverless_v2_cluster_endpoint" {
  description = "Writer endpoint for the cluster"
  value       = module.aurora_serverless_v2.cluster_endpoint
}

output "aurora_serverless_v2_cluster_reader_endpoint" {
  description = "A read-only endpoint for the cluster, automatically load-balanced across replicas"
  value       = module.aurora_serverless_v2.cluster_reader_endpoint
}

output "aurora_serverless_v2_cluster_port" {
  description = "The database port"
  value       = module.aurora_serverless_v2.cluster_port
}

output "aurora_serverless_v2_cluster_engine_version_actual" {
  description = "The running version of the cluster database"
  value       = module.aurora_serverless_v2.cluster_engine_version_actual
}

# database_name is not set on `aws_rds_cluster` resource if it was not specified, so can't be used in output
output "aurora_serverless_v2_cluster_database_name" {
  description = "Name for an automatically created database on cluster creation"
  value       = module.aurora_serverless_v2.cluster_database_name
}

output "aurora_serverless_master_user_secret_name" {
  description = "The base name of the Secrets manager secret for the Aurora master user"
  value = try(
    regex("secret:(.+)-[a-zA-Z0-9]+$", module.aurora_serverless_v2.cluster_master_user_secret[0].secret_arn),
    null
  )
}

output "aurora_serverless_v2_cluster_master_username" {
  description = "The database master username"
  value       = module.aurora_serverless_v2.cluster_master_username
  sensitive   = true
}

output "aurora_serverless_v2_cluster_master_user_secret" {
  description = "The generated database master user secret when `manage_master_user_password` is set to `true`. Contains 'username' and 'password'"
  value       = module.aurora_serverless_v2.cluster_master_user_secret
}

output "aurora_serverless_v2_cluster_hosted_zone_id" {
  description = "The Route53 Hosted Zone ID of the endpoint"
  value       = module.aurora_serverless_v2.cluster_hosted_zone_id
}

# aws_rds_cluster_instances
output "aurora_serverless_v2_cluster_instances" {
  description = "A map of cluster instances and their attributes"
  value       = module.aurora_serverless_v2.cluster_instances
}

output "aurora_serverless_v2_cluster_security_group_id" {
  description = "The security group id for this db cluster"
  value       = module.aurora_serverless_v2.security_group_id
}
