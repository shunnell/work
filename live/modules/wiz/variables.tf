variable "external_id" {
  type        = string
  description = "Connector External ID"
  validation {
    condition     = can(regex("\\S{8}-\\S{4}-\\S{4}-\\S{4}-\\S{12}", var.external_id))
    error_message = "The external_id must match the pattern XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX (UUID format)."
  }
}

variable "master_account_id" {
  type        = string
  description = "AWS Account ID of the account which will contain the static IAM user used (temporarily, pending Wiz's resolution of Gov/Commercial integration defects) by Wiz actual"
}

variable "assume_role_principals" {
  type        = set(string)
  default     = []
  description = "IAM principals (in addition to any static IAM user/role principals created inside this module) that can assume the Wiz role(s) created in this module. Assuming principals must authenticate via 'external_id' in order to assume the Wiz role(s)."
}

variable "lightsail-scanning" {
  type        = bool
  default     = false
  description = "Enable Lightsail scanning"
}

variable "data-scanning" {
  type        = bool
  default     = false
  description = "Enable DSPM data scanning"
}

variable "eks-scanning" {
  type        = bool
  default     = false
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
  default     = true
  description = "Enable Terraform Bucket scanning"
}

variable "cloud-cost-scanning" {
  type        = bool
  default     = true
  description = "Enable Cloud Cost scanning"
}
