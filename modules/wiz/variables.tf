variable "external_id" {
  type        = string
  description = "Connector External ID"
  validation {
    condition     = can(regex("\\S{8}-\\S{4}-\\S{4}-\\S{4}-\\S{12}", var.external_id))
    error_message = "The external_id must match the pattern XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX (UUID format)."
  }
}

variable "wiz_external_role_arns" {
  type        = set(string)
  default     = []
  description = "IAM roles that can assume the Wiz role(s) created in this module. Assuming principals must authenticate via 'external_id' in order to assume the Wiz role(s)."
}

variable "lightsail-scanning" {
  type        = bool
  description = "Enable Lightsail scanning"
}

variable "data-scanning" {
  type        = bool
  description = "Enable DSPM data scanning"
}

variable "eks-scanning" {
  type        = bool
  description = "Enable EKS scanning"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "wiz-defend-s3-kms-policy" {
  description = "(Optional) Enable Wiz Defend S3 KMS policy"
  type        = bool
  default     = true
}

variable "wiz-defend-rds-policy" {
  description = "(Optional) Enable Wiz Defend RDS policy"
  type        = bool
  default     = true
}

variable "wiz-defend-awslogs-policy" {
  description = "(Optional) Enable Wiz Defend AWS Logs policy"
  type        = bool
  default     = true
}

variable "terraform-bucket-scanning" {
  type        = bool
  description = "Enable Terraform Bucket scanning"
}

variable "cloud-cost-scanning" {
  type        = bool
  description = "Enable Cloud Cost scanning"
}
