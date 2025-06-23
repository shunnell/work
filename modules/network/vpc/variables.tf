variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "enable_dns" {
  description = "Enable DNS in VPC"
  type        = bool
  default     = true
}

variable "block_public_access" {
  description = "Whether to block public network access to/from this VPC. Should be 'true' in almost all cases"
  type        = bool
  default     = true
}

variable "private_subnet_width" {
  description = "Width in bits that each subnet will claim in IP addressing space. If the VPC CIDR is a /16, a width of 4 means that subnets will be placed in /20 ranges within that CIDR."
  type        = number
  default     = 4
}

variable "availability_zones" {
  description = "Availability zones in which this VPC will create subnets"
  type        = set(string)
}

variable "force_subnet_cidr_ranges" {
  description = "Should not normally be set. Overrides subnet-width-based selection of CIDR ranges for subnets. Map of AZ => CIDR."
  type        = map(string)
  default     = {}
}

variable "interface_endpoints" {
  description = "Interface endpoints for AWS services whose endpoints are not created by the default compliance config in this module"
  type        = set(string)
  default = [
    # Most of these are required by NIST-800-53 compliance scans.
    # The remainder are useful often enough that it's worth configuring them everywhere.
    "ec2",
    "ec2messages",
    "ecr.api",
    "ecr.dkr",
    "eks",
    "elasticloadbalancing",
    "guardduty-data",
    "inspector-scan",
    "inspector2",
    "kms",
    "logs",
    "rds",
    "secretsmanager",
    # "ssm-contacts", -- unavailable in some AZs, pending AWS ticket to resolve
    "ssm-incidents",
    "ssm",
    "ssmmessages",
    "sts",
  ]
}

variable "gateway_endpoints" {
  description = "Gateway endpoints for AWS services"
  type        = set(string)
  default     = ["s3"]
  validation {
    condition     = alltrue([for e in var.gateway_endpoints : !contains(var.interface_endpoints, e)])
    error_message = "Gateway endpoints cannot be listed in interface_endpoints"
  }
}

variable "log_shipping_destination_arn" {
  description = "Cloudwatch::Logs::Destination ARN to ship internally-generated flow logs from CloudWatch logs to Splunk (ARN supplied via the monitoring/cloudwatch_log_shipping_destination module)"
  type        = string
}

variable "enable_dns_profile" {
  description = "Enable DNS profile"
  type        = bool
  default     = true
}

variable "custom_cidr_range" {
  description = "Custom CIDR range for the VPC endpoints security group rule used for shared services vpc"
  type        = string
  default     = null
}

variable "profile_id" {
  description = "Route53 Profiles ID"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "block_public_access" {
  description = "Should be 'true' in most cases, except for ALB Ingress"
  type        = bool
  default     = true
}

variable "create_public_subnets" {
  description = "Only set to true for ALB ingress VPCs"
  type        = bool
  default     = false
}
