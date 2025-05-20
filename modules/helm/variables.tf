# Helm required
variable "chart" {
  description = "Chart name to be installed. A path may be used"
  type        = string
}

variable "release_name" {
  description = "Release name. The length must not be longer than 53 characters"
  type        = string
}

# Helm optional
variable "atomic" {
  description = "If set, installation process purges chart on fail"
  type        = bool
  default     = false
}

variable "chart_version" {
  description = "Specify the exact chart version to install. If this is not specified, the latest version is installed"
  type        = string
  default     = null
}

variable "cleanup_on_fail" {
  description = "Allow deletion of new resources created in this upgrade when upgrade fails"
  type        = bool
  default     = true
}

variable "create_namespace" {
  description = "Should the namespace be created if it does not exist?"
  type        = bool
  default     = false
}

variable "dependency_update" {
  description = "Run helm dependency update before installing the chart"
  type        = bool
  default     = true
}

variable "force_update" {
  description = "Force resource update through delete/recreate if needed"
  type        = bool
  default     = false
}

variable "max_history" {
  description = "Limit the maximum number of revisions saved per release. Use 0 for no limit"
  type        = number
  default     = 3
}

variable "namespace" {
  description = "Namespace to install chart into"
  type        = string
  default     = "default"
}

variable "recreate_pods" {
  description = "Perform pods restart during upgrade/rollback"
  type        = bool
  default     = true
}

variable "replace" {
  description = "Re-use the given name, even if that name is already used. This is unsafe in production"
  type        = bool
  default     = false
}

variable "repository" {
  description = "Repository where to locate the requested chart. If is a URL the chart is installed without installing the repository"
  type        = string
  default     = null
}

variable "repository_ca_file" {
  type    = string
  default = null
}

variable "repository_cert_file" {
  type    = string
  default = null
}

variable "repository_key_file" {
  type    = string
  default = null
}

variable "repository_password" {
  type    = string
  default = null
}

variable "repository_username" {
  type    = string
  default = null
}

variable "set" {
  description = "Custom values to be merged with the values"
  type        = map(string)
  default     = {}
}

variable "set_list" {
  description = "Custom list values to be merged with the values"
  type        = map(list(string))
  default     = {}
}

variable "set_sensitive" {
  description = "Custom sensitive values to be merged with the values"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "skip_crds" {
  description = "If set, no CRDs will be installed. By default, CRDs are installed if not already present"
  type        = bool
  default     = false
}

variable "timeout" {
  description = "Time in seconds to wait for any individual kubernetes operation."
  type        = number
  default     = 300
}

variable "upgrade_install" {
  description = "The provider will install the release at the specified version even if a release not controlled by the provider is present: this is equivalent to running 'helm upgrade --install' with the Helm CLI. WARNING: this may not be suitable for production use"
  type        = bool
  default     = true
}

variable "values" {
  description = "List of values in raw yaml format to pass to helm"
  type        = list(string)
  default     = []
}
