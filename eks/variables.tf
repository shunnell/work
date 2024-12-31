variable "ami_worker" {
  description = "AMI for Worker"
  type        = string
}

variable "capacity_type" {
  description = "Capacity type (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"
}

variable "cluster_log_types" {
  description = "Enabled Cluster Log Types"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cluster_name" {
  description = "EKS Cluster"
  type        = string
  default     = "cloud-city"
}

variable "cluster_version" {
  description = "Cluster Version"
  type        = string
  default     = "1.30"
}

variable "cluster_role_arn" {
  description = "Cluster Role ARN"
  type        = string
}

variable "desired_size" {
  description = "Scale Desired Size"
  type        = number
}

variable "iam_role_name" {
  description = "IAM role name for EKS cluster"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.large"
}

variable "max_size" {
  description = "Scale Max Size"
  type        = number
}

variable "min_size" {
  description = "Scale Min Size"
  type        = number
}

variable "node_disk_size" {
  description = "Disk size"
  type        = number
  default     = 200
}

variable "node_role_arn" {
  description = "Role ARN"
  type        = string
}

# variable "node_groups" {
#   description = "Node Groups"
#   type = list(object({
#     node_role_arn = string
#     subnet_ids    = list(string)
#     scaling_config = object({
#       desired_size = number
#       min_size     = number
#       max_size     = number
#     })
#   }))
# }

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "subnet_ids" {
  description = "List of Subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to the EKS cluster"
  type        = map(string)
  default     = {}
}

