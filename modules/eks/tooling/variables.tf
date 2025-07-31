variable "cluster_name" {
  description = "EKS Cluster"
  type        = string
}

variable "root_ca_arn" {
  description = "ARN of the root CA"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "List of allowed CIDRs that may access services through the LB"
  type        = list(string)
}

variable "root_domain_name" {
  description = "Domain name that this cluster is expecting to recieve traffic on, including subdomains. Ex: data-platform.sandbox.cloud-city, or dev.cloud-city"
  type        = string
}

variable "argocd_namespace" {
  description = "Namespace of ArgoCD deployment"
  type        = string
}

variable "argocd_domain_name" {
  description = "Domain name for ArgoCD deployed in cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID; will disable the AWS Load Balancer Controller if null"
  type        = string
  nullable    = true
}

variable "nodegroup_security_group_id" {
  description = "Security group for all nodes; will disable the AWS Load Balancer Controller if null"
  type        = string
  nullable    = true
}

variable "aws_ecr_service_account" {
  description = "Service account for use with ArgoCD applications"
  type        = string
  nullable    = true
}

variable "traefik_crds_helm_chart_version" {
  description = "Version of the Helm chart for Traefik and Gateway API CRDs"
  type        = string
  default     = "1.9.0"
}

variable "traefik_helm_chart_version" {
  description = "Version of the Helm chart for Traefik"
  type        = string
  default     = "36.3.0"
}

variable "aws_lbc_helm_chart_version" {
  description = "Version of the Helm chart for AWS Load Balancer Controller"
  type        = string
  default     = "1.13.3"
}

variable "cert_manager_helm_chart_version" {
  description = "Version of the Helm chart for Cert-Manager"
  type        = string
  default     = "v1.18.2"
}

variable "aws_pca_helm_chart_version" {
  description = "Version of the Helm chart for AWS Private CA"
  type        = string
  default     = "v1.6.0"
}

variable "reloader_helm_chart_version" {
  description = "Version of the Helm chart for Reloader"
  type        = string
  default     = "2.1.4"
}

variable "api_gateway_replicas" {
  description = "Replicas of API Gateway controller"
  type        = number
  default     = 2
}

variable "chart_ecr_image_account_id" {
  description = "AWS Account ID containing chart images to be used by this module. Should not ordinarily be changed from the default (the infra account)"
  type        = string
  default     = "381492150796"
}

variable "tags" {
  description = "Tags to apply to AWS resources"
  type        = map(string)
  default     = {}
}
