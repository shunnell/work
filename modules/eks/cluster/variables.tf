variable "cluster_name" {
  description = "EKS Cluster"
  type        = string
  validation {
    condition     = trimspace(var.cluster_name) == var.cluster_name && length(var.cluster_name) > 0
    error_message = "If set, must have a value and no leading or trailing whitespace"
  }
}

variable "kuberenetes_version" {
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

variable "cluster_security_group_rules" {
  description = "Additional custom security group rules for the cluster control plane; should be a list of fields accepted by modules/network/security_group_traffic. Rules required for EKS operation and connection to VPC endpoints are automatically created and should not be specified."
  type = map(object({
    protocol = optional(string)
    type     = string
    ports    = list(number)
    target   = string
    // create_explicit_egress_to_target_security_group intentionally omitted; it is handled automatically internally for the cluster.
  }))
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

# NODEGROUPS

variable "node_groups" {
  description = "Map of Node Group objects, each of which may"
  type = map(object({
    # TODO if we ever use node autoscaling, this can be broadened to allow either a number (static size) or a tuple/map of min/desired/max:
    size     = number
    min_size = optional(number, null) # for increasing size
    max_size = optional(number, null) # for decreasing size
    # Big enough to deploy infrastructure tooling and get started with tenant deployments:
    # preferably, one of https://docs.aws.amazon.com/ec2/latest/instancetypes/ec2-nitro-instances.html
    instance_type    = optional(string, "t3.xlarge")
    volume_size      = optional(number, 20)
    xvdb_volume_size = optional(number, null) # for EBS volume specified by the AMI
    labels           = optional(map(string), {})
    security_group_rules = map(object({
      protocol = optional(string)
      type     = string
      ports    = list(number)
      target   = string
      # create_explicit_egress_to_target_security_group intentionally omitted and defaults to false, as the third party
      # EKS module sets up an all-outbound rule.
    }))
    additional_iam_policy_arns = optional(list(string), [])
  }))
  validation {
    condition     = alltrue([for _, v in var.node_groups : tobool(v.volume_size >= 20)])
    error_message = "Disk sizes must be greater than, or equal to, 20GB"
  }
  validation {
    condition     = alltrue([for _, v in var.node_groups : contains(local.instance_types, v.instance_type)])
    error_message = "Instance type must be one of the supported instance types"
  }
  validation {
    condition = alltrue([
      for _, v in var.node_groups : (v.min_size == null || v.max_size == null ? true : v.min_size < v.max_size)
    ])
    error_message = "Min_Size must be less than Max_Size"
  }
  validation {
    condition = alltrue([
      for _, v in var.node_groups : (v.min_size == null ? true : v.min_size < v.size)
    ])
    error_message = "Min_Size must be less than Size"
  }
  validation {
    condition = alltrue([
      for _, v in var.node_groups : (v.max_size == null ? true : v.size < v.max_size)
    ])
    error_message = "Size must be less than Max_Size"
  }
}

variable "cloudwatch_log_shipping_destination_arn" {
  description = "ARN to ship CloudWatch logs generated in this cluster to (usually in a remote account for subsequent shipment to splunk). Temporarily allowed to be null, in which case logs will not be shipped, just stored locally."
  type        = string
}

# OTHER
variable "tags" {
  description = "Tags to apply to the EKS cluster"
  type        = map(string)
  default     = {}
}
