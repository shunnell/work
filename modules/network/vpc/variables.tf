variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in VPC"
  type        = bool
  default     = true
}

variable "instance_tenancy" {
  description = "Instance tenancy option"
  type        = string
  default     = "default"
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = []
}

variable "create_igw" {
  description = "Controls if an Internet Gateway is created"
  type        = bool
  default     = false
}

variable "create_public_subnets" {
  description = "Controls if public subnets should be created"
  type        = bool
  default     = false
}

variable "create_private_subnets" {
  description = "Controls if private subnets should be created"
  type        = bool
  default     = true
}

variable "create_nat_gateway" {
  description = "Controls if NAT Gateway(s) should be created"
  type        = bool
  default     = false
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways to create"
  type        = number
  default     = 1
}

variable "map_public_ip_on_launch" {
  description = "Should be false if you do not want to auto-assign public IP on launch"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = false
}

variable "flow_logs_destination_arn" {
  description = "ARN of the destination for VPC Flow Logs"
  type        = string
  default     = ""
}

variable "flow_logs_traffic_type" {
  description = "The type of traffic to capture. Valid values: ACCEPT, REJECT, ALL"
  type        = string
  default     = "ALL"
}

variable "flow_logs_role_arn" {
  description = "The ARN for the IAM role that's used to post flow logs to CloudWatch Logs"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
