variable "aws_profile" {
  description = "AWS Profile"
  type        = string
  default     = null
}

variable "ami_type" {
  description = "AMI Type for Worker"
  type        = string
  default = "BOTTLEROCKET_x86_64"
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
}

variable "cluster_version" {
  description = "Cluster Version"
  type        = string
  default     = "1.31"
}

variable "cluster_role_arn" {
  description = "Cluster Role ARN"
  type        = string
}

variable "desired_size" {
  description = "Scale Desired Size"
  type        = number
}

variable "existing_node_role_arn" {
  description = "The ARN of the existing IAM role to use for the EKS node group"
  type        = string
}

variable "iam_role_name" {
  description = "IAM role name for EKS cluster"
  type        = string
  default     = "eks-node-group-role"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "m5.large"
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

variable "policy_file_path" {
  description = "Path to the policy JSON file"
  type        = string
  default     = "../../live/_envcommon/platform/eks/policy/data.json"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "security_group_ids" {
  description = "Security Group IDs"
  type        = list(string)
  default = [ "sg-087f9ed0b107ba48b" ]
  
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

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = "vpc-01912bb2c7a00113e"
  
}

