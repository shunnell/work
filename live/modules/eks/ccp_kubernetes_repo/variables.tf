variable "cluster_name" {
  description = "EKS Cluster"
  type        = string
}

variable "argocd_namespace" {
  description = "Kubernetes namespace which contains ArgoCD"
  type        = string
  default     = "argocd"
}

variable "k8s_repo_secret_name" {
  description = "Name of the deploy key and user for the repo in Secret Manager"
  type        = string
}

variable "k8s_repo_secret_user_key" {
  description = "Name of the deploy user for the repo in Secret Manager"
  type        = string
  default     = "user"
}

variable "k8s_repo_secret_token_key" {
  description = "Name of the deploy key for the repo in Secret Manager"
  type        = string
  default     = "key"
}

variable "k8s_repo_target_revision" {
  description = "Revision/branch/tag to reference in target repository"
  type        = string
  default     = "HEAD"
}
