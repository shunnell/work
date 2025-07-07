variable "cluster_name" {
  description = "EKS Cluster"
  type        = string
}

variable "enable_argocd" {
  type        = bool
  default     = true
  description = "Whether to provision ArgoCD on this cluster"
  validation {
    condition     = var.enable_argocd ? var.enable_aws_load_balancer_controller : true
    error_message = "'enable_aws_load_balancer_controller' must be true if 'enable_argocd' is true"
  }
}


variable "enable_aws_load_balancer_controller" {
  type        = bool
  default     = true
  description = "Whether to provision the AWS load balancer controller (LBC) on this cluster"
}


variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "nodegroup_security_group_id" {
  description = "Security group for the LoadBalancer to use"
  type        = string
}

variable "account_name" {
  description = "Internal name of the AWS account this is in. Used for auto-deploying cluster resources"
  type        = string
}

variable "chart_ecr_image_account_id" {
  description = "AWS Account ID containing chart images to be used by this module. Should not ordinarily be changed from the default (the infra account)"
  type        = string
  default     = "381492150796"
}

variable "tags" {
  description = "Tags to apply to the EKS cluster"
  type        = map(string)
  default     = {}
}
