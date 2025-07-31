variable "cluster_name" {
  description = "EKS Cluster"
  type        = string
  validation {
    condition     = trimspace(var.cluster_name) == var.cluster_name && length(var.cluster_name) > 0
    error_message = "If set, must have a value and no leading or trailing whitespace"
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version to install; change this for existing clusters with care, as upgrades may be disruptive and require changes to cluster workloads"
  type        = string
  default     = "1.32"
}

variable "nodegroup_change_unavailable_percentage" {
  description = "Percentage of nodes that can be offline during an upgrade. Higher means faster terraform applies, but more potential for temporary workload unavailability"
  type        = number
  default     = 75
  validation {
    condition     = var.nodegroup_change_unavailable_percentage > 10 && var.nodegroup_change_unavailable_percentage <= 100
    error_message = "Must be between 10 and 100"
  }
}

variable "subnet_ids" {
  description = "Subnet IDs"
  type        = list(string)
  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "At least 1 subnet ID must be passed"
  }
  validation {
    condition     = alltrue([for s in var.subnet_ids : startswith(s, "subnet-")])
    error_message = "All subnet IDs must start with 'subnet-'"
  }
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  validation {
    condition     = startswith(var.vpc_id, "vpc-")
    error_message = "VPC ID must start with 'vpc-'"
  }
}

variable "administrator_role_arns" {
  description = "List of role ARNs that should have full administrator access to the cluster"
  type        = list(string)
  validation {
    condition     = alltrue([for v in var.administrator_role_arns : can(regex("^arn:aws:iam::\\d{12}:role/.+$", v))])
    error_message = "Must be a list of ARN(s)"
  }
}

variable "access_entries" {
  description = "Map of access entries to add to the cluster"
  type        = map(any)
  default     = {}
}

variable "node_groups" {
  description = "Map of Node Group objects, each of which may"
  type = map(object({
    # TODO if we ever use node autoscaling, this can be broadened to allow either a number (static size) or a tuple/map of min/desired/max:
    size = number
    # m5.large is big enough to deploy infrastructure tooling and get started with tenant deployments, tested on
    # multiple tenants small/ordinary/baseline deployments:
    instance_type              = optional(string, "m5.large")
    volume_size                = optional(number, 20)
    xvdb_volume_size           = optional(number, null) # for EBS volume specified by the AMI
    labels                     = optional(map(string), {})
    additional_iam_policy_arns = optional(list(string), [])
  }))
  validation {
    condition     = alltrue([for _, v in var.node_groups : (v.volume_size >= 20 && coalesce(v.xvdb_volume_size, v.volume_size) >= 20)])
    error_message = "Disk sizes must be greater than, or equal to, 20GB"
  }
  validation {
    condition     = alltrue([for _, v in var.node_groups : contains(local.instance_types, v.instance_type)])
    error_message = "Instance type must be one of the supported instance types"
  }
  validation {
    condition     = alltrue([for k in keys(var.node_groups) : !contains(["all", ""], k)])
    error_message = "String not allowed as nodegroup name"
  }
}

variable "cloudwatch_log_shipping_destination_arn" {
  description = "ARN to ship CloudWatch logs generated in this cluster to (usually in a remote account for subsequent shipment to splunk). Temporarily allowed to be null, in which case logs will not be shipped, just stored locally."
  type        = string
}

variable "kubernetes_control_plane_allowed_cidrs" {
  description = "CIDR ranges which can access port 443 on the kubernetes control plane (this is just for kubectl/tf/helm access, not the nodes; node access should be done by referencing the 'node_groups.[*].security_group_id')"
  type        = set(string)
  default     = []
}

variable "legacy_nodegroup_sg_name" {
  type        = string
  description = "Whether to keep legacy-naming-scheme SGs around for nodegroups (tenants may have added rules referencing those SGs); should eventually go to 'false' everywhere"
  nullable    = true
  default     = null
}

variable "tags" {
  description = "Tags to apply to the EKS cluster"
  type        = map(string)
  default     = {}
}
