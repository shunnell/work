variable "name_prefix" {
  description = "Prefix used to name all resources (e.g. 'env-app')."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the ALB and target groups will live."
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs (at least two) where the ALB will attach."
  type        = list(string)
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate to use on the HTTPS listener."
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "tenants" {
  description = <<-EOF
Map of tenant configurations. Each key is an arbitrary tenant‐identifier string,
and each value is an object with:
- host_header       = the hostname to match (e.g. 'tenant1.example.com')
- priority          = integer priority for listener rule (1–50000)
- port              = port that the tenant’s application listens on (e.g. 80 or 8080)
- protocol          = (optional) protocol for the target group (defaults to "HTTP")
- health_check_path = (optional) path for health checks (defaults to "/")
EOF
  type = map(object({
    host_header       = string
    priority          = number
    port              = number
    protocol          = optional(string)
    health_check_path = optional(string)
  }))
}

variable "waf_web_acl_id" {
  description = "ID of the AWS WAF Classic (Regional) Web ACL to associate; omit or null to skip"
  type        = string
  default     = null
}

