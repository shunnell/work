variable "eks_tag_key" {
  type        = string
  description = "EC2 tag key used by EKS nodes"
  default     = "eks:cluster-name"
}

variable "ssm_document_name" {
  type        = string
  description = "Name for the SSM document that enables the GuardDuty agent"
  default     = "EnableGuardDutyRuntimeAgent"
}
