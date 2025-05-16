variable "cluster_name" {
  description = "EKS Cluster name (required by terraform provider setup even if not used by this module)"
  type        = string
}

variable "name" {
  description = "Name of the IRSA role (will be the name of the created service account, and the name *prefix* of the created IAM role)"
  type        = string
  default     = null
}

variable "use_name_as_iam_role_prefix" {
  description = "Name of the IRSA role will be distinct (not a prefix)"
  type        = bool
  default     = false
}

variable "namespace" {
  description = "Namespace in which service account should be created"
  type        = string
}

variable "description" {
  description = "Description of the purpose of this role"
  type        = string
  default     = ""
}

variable "iam_policy_arns" {
  description = "ARNs of any custom, externally-created policies to attach to the IAM role."
  type        = set(string)
  default     = []
}

variable "create_service_account" {
  description = "Whether to create the Kubernetes service acount that the IRSA role is bound to. Only disable this if the service account is unconditionally created elsewhere (e.g. in a helm chart which cannot disable the creation of its own SA)"
  type        = bool
  default     = true
}

variable "secret_arns" {
  description = "ARNs SecretsManager secrets or KMS keys to grant this role permission to use via the external secrets operator. If empty, the external secrets operator's permissions won't be attached to this IRSA role."
  type        = set(string)
  default     = []
  validation {
    condition     = alltrue([for arn in var.secret_arns : (startswith(arn, "arn:aws:kms") || startswith(arn, "arn:aws:secretsmanager"))])
    error_message = "Values must be KMS key ARNs or SecretsManager secret ARNs"
  }
}

# NB: We are not using the "target group only" restricted pattern for the LBC policy. If that is desired at some point,
# this module can be updated to support it. More details here:
# https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/deploy/installation/#option-b-attach-iam-policies-to-nodes
variable "use_load_balancer_controller" {
  description = "Whether or not to set up permissions for this IRSA role to use the AWS Load Balancer controller"
  type        = bool
  default     = false
}

variable "use_cluster_autoscaler" {
  description = "Whether or not to set up permissions for this IRSA role to use the cluster autoscaler controller"
  type        = bool
  default     = false
}

variable "use_cloudwatch_observability" {
  description = "Whether or not to set up permissions for this IRSA role to use the CloudWatch observability addon"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add the the IAM role"
  type        = map(string)
  default     = {}
}
