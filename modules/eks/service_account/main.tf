module "irsa_role" {
  source = "git::https://gitlab.cloud-city/terraform-aws-modules/terraform-aws-iam.git//modules/iam-role-for-service-accounts-eks"

  role_name          = var.use_name_as_iam_role_prefix ? null : var.name
  role_name_prefix   = var.use_name_as_iam_role_prefix ? "irsa-${var.name}" : null
  policy_name_prefix = "for-irsa-${var.name}"

  role_description = var.description
  tags             = var.tags
  # The module wants a map, but our API is a set, so map-ify it. The map's keys aren't used anywhere anyway:
  role_policy_arns = { for arn in var.iam_policy_arns : arn => arn }
  # Some usages of this module in GitLab will be simplified if it can assume itself. While that's ordinarily a bit of
  # a code smell, it doesn't harm any security boundaries, so it's enabled by default here:
  allow_self_assume_role = true
  create_role            = true # The default
  # Since we always fully own the role, make destruction more reliable by forcibly detaching policies on destroy:
  force_detach_policies = true
  oidc_providers = {
    default = {
      provider_arn = local.oidc_arn
      namespace_service_accounts = [
        "${var.namespace}:${var.name}"
      ]
    }
  }
  # Below, we set up specific "pre-made" policies for various common EKS systems.
  # TODO it might be worth assessing whether we want to allow all of those, or whether the variable API of this module
  # should nudge folks towards creating an IRSA role that can only do one thing.

  # Cluster autoscaler stuff:
  attach_cluster_autoscaler_policy = var.use_cluster_autoscaler
  cluster_autoscaler_cluster_ids   = var.use_cluster_autoscaler ? [data.aws_eks_cluster.cluster.id] : null

  # Secrets manager stuff:
  attach_external_secrets_policy = length(var.secret_arns) > 0
  # The IRSA module has a bug where it creates invalid policies if no KMS secret ARN is supplied, so we give it an
  # invalid ARN to work around that. Ref: https://github.com/terraform-aws-modules/terraform-aws-iam/pull/550
  external_secrets_kms_key_arns         = length(local.kms_secret_arns) == 0 ? ["arn:aws:fake:::fake"] : local.kms_secret_arns
  external_secrets_secrets_manager_arns = length(local.secretsmanager_secret_arns) == 0 ? null : local.secretsmanager_secret_arns
  # We never want to allow creation of secrets from within EKS; secrets must be created externally in IaC.
  external_secrets_secrets_manager_create_permission = false

  # CloudWatch observability addon stuff
  attach_cloudwatch_observability_policy = var.use_cloudwatch_observability

  # LBC stuff:
  attach_load_balancer_controller_policy = var.use_load_balancer_controller

  # External-DNS stuff:
  attach_external_dns_policy = var.use_external_dns
}

# Creates Service account and points to above irsa role
resource "kubernetes_service_account" "this" {
  count = var.create_service_account ? 1 : 0
  metadata {
    name      = var.name
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.irsa_role.iam_role_arn
    }
  }
}
