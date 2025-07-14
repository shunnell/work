variable "project_name" {
  description = "Name of the ArgoCD AppProject"
  type        = string
  validation {
    condition     = var.project_name != "default"
    error_message = "AppProject name cannot be 'default'"
  }
}

variable "argocd_namespace" {
  description = "Namespace of ArgoCD deployemnt"
  type        = string
  default     = "argocd"
}

variable "project_configuration" {
  description = "Configuration of AppProject. Please reference https://argo-cd.readthedocs.io/en/stable/user-guide/projects/ for specification"
  type        = any
}
