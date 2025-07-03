variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster that will contain the runners"
}

variable "chart_version" {
  description = "Version of the GitLab Runners Helm chart to install"
  type        = string
}

variable "gitlab_mothership_domain" {
  type        = string
  description = "Domain of the GitLab mothership server. Must be reachable from the EKS cluster's nodegroup security group."
  validation {
    condition     = !strcontains(var.gitlab_mothership_domain, "/")
    error_message = "Must not contain slashes"
  }
}

variable "concurrency_pods" {
  type = number
  # TODO a HPA is available if we can hook up telemetry, but that's a lot of infra to stand up
  default     = 4
  description = "How many runner pods to provision"
  validation {
    condition     = var.concurrency_pods > 0
    error_message = "Must be a number greater than zero"
  }
}

variable "concurrency_jobs_per_pod" {
  type        = number
  default     = 6 # Chart default is 10 but that can get CPU-load-ey
  description = "How many jobs can be run within each runner pod"
  validation {
    condition     = var.concurrency_jobs_per_pod > 0
    error_message = "Must be a number greater than zero"
  }
}

# TODO this will be replaced with an external secret locator once we agree on how to deploy SSM-managed EKS secrets everywhere
variable "gitlab_certificate" {
  type        = string
  description = "SSL certificate used for authenticating the runners with the mothership"
  sensitive   = true
  validation {
    condition     = !can(base64decode(var.gitlab_certificate))
    error_message = "Must be raw cert - do not 'encrypt' with Base64"
  }
}

variable "gitlab_certificate_path" {
  description = "Location to mount the GitLab certificate"
  type        = string
  default     = "/etc/gitlab-runner/certs/"
}

variable "gitlab_secret_id" {
  description = "AWS Secrets Manager ID containing the GitLab instance's secrets, including runner join tokens. The secret at this ID must contain a JSON object with a key corresponding to 'runner_fleet_name' and a value containing 'token' with the join token for this fleet."
  type        = string
}

variable "tenant_name" {
  description = "Name of the tenant whose jobs run on these runners"
  type        = string
}

variable "runner_fleet_name_suffix" {
  type        = string
  description = "Suffix to be added to var.tenant name to identify resources related to these runners. $tenant_name-$runner_fleet_name_suffix must be globally unique in the account"
  default     = "default"
  validation {
    condition     = can(regex("^\\w+$", var.runner_fleet_name_suffix))
    error_message = "Must be set to a non-empty string containing no spaces"
  }
}

variable "runner_image_registry_root" {
  description = "Registry root to be used for runners to find runner, helper, and default job images (note: this does not set a default registry for user jobs; they'll still need explicit full paths for images in specific registries)"
  type        = string
  default     = "381492150796.dkr.ecr.us-east-1.amazonaws.com"
}

variable "runner_iam_policy_attachments" {
  description = "List of IAM policy ARNs to attach to the runners' role"
  default     = []
  type        = list(string)
}

variable "deployer_roles" {
  description = "List of IAM Role ARNs (potentially in other accounts) that these runners can assume (remote roles will need trust policies that allow the runner role to assume them)"
  type        = list(string)
  default     = []
}

variable "runner_is_privilaged" {
  description = "Will runners run in privilaged mode?"
  type        = bool
  default     = false
}

variable "builder_cpu" {
  description = "Minimum CPU allocated for runner main"
  type        = string
  default     = "500m"
  validation {
    condition     = can(regex("^[0-9]+((m)|\\.[0-9]+)?$", var.builder_cpu))
    error_message = "'builder_cpu' must be valid kubernetes resource cpu value"
  }
}

variable "builder_memory" {
  description = "Memory allocated for runner main"
  type        = string
  default     = "2Gi"
  validation {
    condition     = can(regex("^[0-9]+(k|Ki|(G|M|T|P|E)i?)?$", var.builder_memory))
    error_message = "'builder_memory' must be valid kubernetes quantity - https://kubernetes.io/docs/reference/kubernetes-api/common-definitions/quantity/"
  }
}

variable "scratch_space_size_gb" {
  description = "Scratch space size that will be mounted at /builds"
  default     = 6
  type        = number
  validation {
    condition     = var.scratch_space_size_gb >= 6
    error_message = "Must be at least 6. Size in GB"
  }
}

variable "read_only_root" {
  description = "If true, mount the filesystem in the root container as read-only. Only /builds (and a few other log/cache folders) will be read-write. This prevents ephemeral storage exhaustion by code that writes outside of /builds."
  default     = false
  type        = bool
}

variable "service_cpu" {
  description = "Minimum CPU allocated for runner service"
  type        = string
  default     = "500m"
  validation {
    condition     = can(regex("^[0-9]+((m)|\\.[0-9]+)?$", var.service_cpu))
    error_message = "'service_cpu' must be valid kubernetes resource cpu value"
  }
}

variable "service_memory" {
  description = "Memory allocated for runner service"
  type        = string
  default     = "512Mi"
  validation {
    condition     = can(regex("^[0-9]+(k|Ki|(G|M|T|P|E)i?)?$", var.service_memory))
    error_message = "'service_memory' must be valid kubernetes quantity - https://kubernetes.io/docs/reference/kubernetes-api/common-definitions/quantity/"
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "code_artifact_repos" {
  description = "ARNs for CodeArtifact repositories to which this fleet should have access"
  type = object({
    pull         = set(string)
    push         = set(string)
    pull_through = set(string)
  })
  default = {
    pull         = []
    push         = []
    pull_through = []
  }
  validation {
    condition = alltrue([
      for v in values(var.code_artifact_repos) : alltrue([for arn in v : can(regex("^arn:aws:codeartifact:.*:\\d*:(repository|package)/.+$", arn))])
    ])
    error_message = "Each ARN must be a valid AWS ARN for a CodeArtifact respository or package"
  }
}
