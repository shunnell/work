variable "cluster_log_types" {
  description = "Enabled Cluster Log Types"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cluster_name" {
  description = "EKS Cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "K8s Version"
  type        = string
  default     = "1.31"
}

variable "cluster_role_arn" {
  description = "Cluster Role ARN"
  type        = string
}

variable "node_groups" {
  description = "Node Groups"
  type = list(object({
    ami_type      = optional(string, "BOTTLEROCKET_x86_64")
    capacity_type = optional(string, "ON_DEMAND")
    desired_size  = optional(number, 3)
    disk_size     = optional(number, 20)
    instance_type = optional(string, "t3.medium")
    max_size      = optional(number, 6)
    min_size      = optional(number, 3)
    name          = string
    node_role_arn = string
  }))
}

variable "security_group_ids" {
  description = "Security Group IDs"
  type        = list(string)
}

variable "subnet_ids" {
  description = "Subnet IDs"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to the EKS cluster"
  type        = map(string)
  default     = {}
}

variable "vpc_endpoint_sg_id" {
  description = "VPC Endpoint Security Group ID"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "coredns_version" {
  description = "The version of the CoreDNS addon."
  type        = string
  default     = "v1.8.0-eksbuild.1"
}

variable "kube_proxy_version" {
  description = "The version of the kube-proxy addon."
  type        = string
  default     = "v1.19.6-eksbuild.1"
}

variable "vpc_cni_version" {
  description = "The version of the VPC CNI addon."
  type        = string
  default     = "v1.7.5-eksbuild.1"
}

variable "cloudwatch_observability_version" {
  description = "The version of the Amazon CloudWatch Observability agent addon."
  type        = string
  default     = "v0.0.1"
}