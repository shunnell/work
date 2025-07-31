variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}

variable "env_suffix" {
  description = "Suffix to use for resource names (e.g., 'test' for test stacks, '' for production)"
  type        = string
  default     = ""
}

variable "release_name" {
  description = "The name of the release"
  type        = string
}

variable "repository" {
  description = "The repository of the chart to install"
  type        = string
}

variable "chart" {
  description = "The chart to install"
  type        = string
  default     = "nxrm-ha"
}

variable "chart_version" {
  description = "The version of the chart to install"
  type        = string
}

variable "replica_count" {
  description = "The number of replicas to run"
  type        = number
}

variable "busybox_version" {
  description = "The version of the busybox image to use"
  type        = string
  default     = "1.33.1"
}

variable "db_endpoint" {
  description = "The endpoint of the database"
  type        = string
}

variable "rds_secret" {
  description = "Name of the Kubernetes secret containing RDS credentials"
  type        = string
  default     = "postgres-secret"
}

variable "rds_aws_secret" {
  description = "AWS secret name for RDS credentials"
  type        = string
}

variable "license_secret_name" {
  description = "Name of the Kubernetes secret containing license credentials"
  type        = string
  default     = "nexus-repo-license.lic"
}

variable "license_secret_key" {
  description = "The key of the license secret"
  type        = string
}

variable "license_secret_arn" {
  description = "The ARN of the license secret"
  type        = string
}

variable "secret_arn" {
  description = "The ARN of the secret to use"
  type        = list(string)
}

variable "ecr_docker_hub" {
  description = "The ECR host for the Docker hub"
  type        = string
}

variable "ecr_host" {
  description = "The ECR host for the Nexus chart"
  type        = string
}

variable "cluster_issuer" {
  description = "The cluster issuer to use"
  type        = string
  default     = "bespin-root-ca"
}

variable "gateway_class_name" {
  description = "The gateway class name to use"
  type        = string
  default     = "traefik"
}

variable "nexus_domain_name" {
  description = "The domain name for the Nexus service"
  type        = string
}

variable "nexus_acm_certificate_arn" {
  description = "The ARN of the ACM certificate to use"
  type        = string
}

variable "docker_acm_certificate_arn" {
  description = "The ARN of the ACM certificate to use for the Docker registry"
  type        = string
}

variable "tags" {
  description = "The tags to apply to the resources"
  type        = map(string)
}

