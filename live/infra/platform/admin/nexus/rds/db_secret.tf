# the proper way is to use an external secret, but this is temporary

data "aws_secretsmanager_secret" "db_secret" {
  arn = module.aurora_serverless_v2.cluster_master_user_secret[0].secret_arn
}

data "aws_secretsmanager_secret_version" "db_secret" {
  secret_id = data.aws_secretsmanager_secret.db_secret.id
}

output "aurora_serverless_v2_cluster_credentials" {
  description = "contains 'username' and 'password'"
  value       = jsondecode(data.aws_secretsmanager_secret_version.db_secret.secret_string)
  sensitive   = true
}
