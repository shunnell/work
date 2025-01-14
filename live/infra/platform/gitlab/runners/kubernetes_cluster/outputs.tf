output "eks_cluster" {
  value = aws_eks_cluster.gitlab_runner_cluster
}

output "runner_service_account_role_arn" {
  value = aws_iam_role.gitlab_runner_sa_role.arn
}

output "cache_s3_bucket_name" {
  value = aws_s3_bucket.gitlab_cache_bucket.id
}