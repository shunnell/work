variable "gitlab_domain" {
  description = "Domain name for GitLab"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "gitlab_namespace" {
  description = "Kubernetes namespace where GitLab will be deployed"
  type        = string
  default     = "gitlab"
}

variable "gitlab_image_registry_root" {
  description = "Registry root to be used for runners to find runner, helper, and default job images (note: this does not set a default registry for user jobs; they'll still need explicit full paths for images in specific registries)"
  type        = string
  default     = "381492150796.dkr.ecr.us-east-1.amazonaws.com/platform"
}

variable "release_name" {
  description = "Name of the GitLab Helm release"
  type        = string
  default     = null
}

variable "chart_version" {
  description = "Version of the GitLab Helm chart to install"
  type        = string
  default     = null
}

variable "irsa_role" {
  description = "IAM role ARN for IRSA (IAM Roles for Service Accounts)"
  type        = string
  default     = null
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
  default     = null
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
  default     = null
}

variable "acm_cert_arn" {
  description = "ACM cert arn for ingress https connection"
  type        = string
  default     = null
}

variable "rds_endpoint" {
  description = "RDS endpoint"
  type        = string
  default     = null
}

variable "artifacts_bucket" {
  description = "Bucket for artifacts"
  type        = string
  default     = null
}

variable "ci_secure_bucket" {
  description = "Bucket for ci secure"
  type        = string
  default     = null
}

variable "dependency_proxy_bucket" {
  description = "Bucket for dependency proxy"
  type        = string
  default     = null
}

variable "mr_diffs_bucket" {
  description = "Bucket for mr diffs"
  type        = string
  default     = null
}

variable "gitlab_lfs_bucket" {
  description = "Bucket for gitlab lfs"
  type        = string
  default     = null
}

variable "gitlab_pkg_bucket" {
  description = "Bucket for gitlab pkg"
  type        = string
  default     = null
}

variable "tf_state_bucket" {
  description = "Bucket for tf state"
  type        = string
  default     = null
}

variable "gitlab_uploads_bucket" {
  description = "Bucket for gitlab uploads"
  type        = string
  default     = null
}

variable "gitlab_backup_bucket" {
  description = "Bucket for gitlab backup"
  type        = string
  default     = null
}

variable "gitlab_tmp_backup_bucket" {
  description = "Bucket for gitlab tmp backup"
  type        = string
  default     = null
}

variable "rails_s3_secret_name" {
  description = "Rails s3 secret"
  type        = string
  default     = "rails-s3-config"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}