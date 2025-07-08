variable "domain" {
  description = "Domain name for GitLab"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace where GitLab will be deployed"
  type        = string
}

variable "image_registry_root" {
  description = "Registry root to be used for runners to find runner, helper, and default job images (note: this does not set a default registry for user jobs; they'll still need explicit full paths for images in specific registries)"
  type        = string
  default     = "381492150796.dkr.ecr.us-east-1.amazonaws.com/platform"
}

variable "release_name" {
  description = "Name of the GitLab Helm release"
  type        = string
}

variable "chart_version" {
  description = "Version of the GitLab Helm chart to install"
  type        = string
}

variable "irsa_role" {
  description = "IAM role ARN for IRSA (IAM Roles for Service Accounts)"
  type        = string
}

variable "irsa_name" {
  description = "Name of the IAM role for IRSA (IAM Roles for Service Accounts)"
  type        = string
  default     = "service-account"
}

variable "rds_aws_secret" {
  description = "AWS secret name for RDS credentials"
  type        = string
  default     = "postgres-secret"
}

variable "redis_aws_secret" {
  description = "AWS secret name for Redis credentials"
  type        = string
  default     = "redis-secret"
}

variable "rds_secret" {
  description = "Name of the Kubernetes secret containing RDS credentials"
  type        = string
  default     = "postgres-secret"
}

variable "redis_endpoint" {
  description = "Endpoint URL for the Redis instance"
  type        = string
}

variable "redis_secret" {
  description = "Name of the Kubernetes secret containing Redis credentials"
  type        = string
  default     = "redis-secret"
}

variable "s3_secret_name" {
  description = "Secret name for s3 config"
  type        = string
  default     = "s3cmd-config"
}

variable "secret_arn" {
  description = "List of secret arns should be allowed for the service account"
  type        = list(string)
}

variable "acm_cert_arn" {
  description = "ACM cert arn for ingress https connection"
  type        = string
}

variable "rds_endpoint" {
  description = "RDS endpoint"
  type        = string
}

variable "artifacts_bucket" {
  description = "Bucket for artifacts"
  type        = string
}

variable "ci_secure_bucket" {
  description = "Bucket for ci secure"
  type        = string
}

variable "dependency_proxy_bucket" {
  description = "Bucket for dependency proxy"
  type        = string
}

variable "mr_diffs_bucket" {
  description = "Bucket for mr diffs"
  type        = string
}

variable "lfs_bucket" {
  description = "Bucket for gitlab lfs"
  type        = string
}

variable "pkg_bucket" {
  description = "Bucket for gitlab pkg"
  type        = string
}

variable "registry_bucket" {
  description = "Bucket for gitlab registry"
  type        = string
}

variable "pages_bucket" {
  description = "Bucket for gitlab pages"
  type        = string
}

variable "tf_state_bucket" {
  description = "Bucket for tf state"
  type        = string
}

variable "uploads_bucket" {
  description = "Bucket for gitlab uploads"
  type        = string
}

variable "backup_bucket" {
  description = "Bucket for gitlab backup"
  type        = string
}

variable "tmp_backup_bucket" {
  description = "Bucket for gitlab tmp backup"
  type        = string
}

variable "toolbox_storage" {
  description = "How much storage to allocate to toolbox for backups"
  type        = string
  default     = "150Gi"
}

variable "backup_cron_schedule" {
  description = "CRON schedule for GitLab backup"
  type        = string
  default     = "0 1 * * *"
}

variable "backup_cron_extra_args" {
  description = "Extra arguments to pass to the backup-utility during cron backup"
  type        = string
  default     = "--skip uploads,artifacts,pages,lfs,terraform_state,registry,packages,ci_secure_files,external_diffs"
}

variable "rails_s3_secret_name" {
  description = "Rails s3 secret"
  type        = string
  default     = "rails-s3-config"
}

variable "gitlab_secret_id" {
  description = <<-DESC
    AWS Secrets Manager ID containing the GitLab instance's secrets, including OAuth token.
    The secret at this ID must contain a JSON object with a key corresponding to 'oauth_token' and a value of the oauth token.
    DESC
  type        = string
}

variable "ses_api_secret_id" {
  description = "Secrete name for SES API credentials"
  type        = string
  default     = "ses-api-config"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
