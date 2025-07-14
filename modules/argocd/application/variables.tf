variable "argocd_namespace" {
  description = "Namespace of ArgoCD."
  type        = string
  default     = "argocd"
}

variable "argocd_app_project" {
  description = "Project that this ArgoCD Application belongs to. Useful for tenant restrictions."
  type        = string
  default     = "default"
}

variable "aws_ecr_service_account" {
  description = "ServiceAccount with role for ECR access. Required when chart is in AWS ECR."
  type        = string
  nullable    = true
  default     = null
  validation {
    error_message = "Required when chart is in AWS ECR."
    condition     = !can(regex(local.aws_ecr_regex, var.app_helm_chart_repo)) || (can(regex(local.aws_ecr_regex, var.app_helm_chart_repo)) && try(length(var.aws_ecr_service_account), 0) > 0)
  }
}

variable "app_namespace" {
  description = "Namespace that the app will be deployed to."
  type        = string
}

variable "app_name" {
  description = "Name of the app. Defaults to value of 'app_helm_chart' if this is empty/null."
  type        = string
  nullable    = true
  default     = ""
}

variable "app_helm_chart_repo" {
  description = "Repository containing helm chart - not full path of helm chart. ex: '000.dkr.something.ecr.aws.com/platform/internal/helm/stakater'"
  type        = string
}

variable "app_helm_chart" {
  description = "The Helm chart for the app. ex: 'reloader'"
  type        = string
}

variable "app_helm_chart_version" {
  description = "Version of the Helm chart to use. ex: '1.2.3'"
  type        = string
}

variable "app_helm_values" {
  description = "App Helm chart values in YAML format."
  type        = string
  default     = null
  nullable    = true
  validation {
    error_message = "'app_helm_values' must be in YAML format"
    condition     = var.app_helm_values == null || can(yamldecode(var.app_helm_values))
  }
}

variable "app_destination" {
  description = "Destination server of the app"
  type        = string
  default     = "https://kubernetes.default.svc"
}

variable "self_heal" {
  description = "Self-heal app: https://argo-cd.readthedocs.io/en/stable/user-guide/auto_sync/#automatic-self-healing"
  type        = bool
  default     = false
}

variable "prune" {
  description = "Prune app: https://argo-cd.readthedocs.io/en/stable/user-guide/auto_sync/#automatic-pruning"
  type        = bool
  default     = true
}
