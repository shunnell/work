variable "instance_type" {
  type        = string
  description = "EC2 instance type (e.g. \"t3.medium\")."
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID in which to launch the EC2s."
}

variable "vpc_security_group_ids" {
  type        = list(string)
  default     = []
  description = "List of security group IDs to attach to each EC2."
}

variable "instance_profile_name" {
  type        = string
  description = "IAM Instance Profile name to attach for SSM access. If empty, no profile is attached."
  default     = ""
}

variable "enable_guardduty" {
  type        = bool
  description = "Whether to install and enable the GuardDuty runtime agent."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to each EC2."
  default     = {}
}

variable "instance_name_prefix" {
  type        = string
  description = "Prefix to use for each EC2’s Name tag and also the Project tag filter. Example: \"testing-ec2\"."
}

variable "instance_count" {
  type        = number
  description = <<-EOT
    Number of **new** EC2 instances you want to add.  
    Terraform will look up how many EC2s already exist (running or stopped) with tag:Project = instance_name_prefix, 
    then create exactly `instance_count` new ones on top of that.
  EOT
}

variable "name_tag" {
  type    = string
  default = "Enabled"
}
