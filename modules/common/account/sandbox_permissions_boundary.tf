module "iam_fragments" {
  source = "../../iam/fragments"
}

data "aws_iam_policy_document" "sandbox_boundary" {
  source_policy_documents = [
    module.iam_fragments.tenant_development_permissions,
  ]

  # temporary for OPR to access secrets to remediate RED team issues PTTC 007
  # We will remove this once we have a more permanent solution in place.
  # Note that secretsmanager:* is allowed broadly via the source document, so this additional restriction locks it
  # down further, since "Deny"s in permissions boundaries "stack" as if another IAM policy was attached to a role.
  dynamic "statement" {
    for_each = var.account_name == "opr" ? [1] : []
    content {
      sid    = "DenyNonOPRSecretAccess"
      effect = "Deny"
      actions = [
        "secretsmanager:GetSecretValue",
      ]
      not_resources = [
        "arn:aws:secretsmanager:*:*:secret:${var.account_name}/*",
        "arn:aws:secretsmanager:*:*:secret:${var.account_name}-*",
        "arn:aws:secretsmanager:*:*:secret:rds*",
      ]
    }
  }
}

locals {
  policies = {
    SandboxPermissionsBoundary = [
      "PermissionsBoundary for IAM roles created by Sandbox_Dev. To prevent priviledge escalation, this role cannot perform any IAM modifications. It's also limited to using known services.",
      data.aws_iam_policy_document.sandbox_boundary.json,
    ]
    NoAccess = [
      "Restriction-only policy that disallows all access to all resources.",
      module.iam_fragments.zero_access,
    ]
  }
}

moved {
  from = module.sandbox_permissions_boundary
  to   = module.policies["SandboxPermissionsBoundary"]
}

module "policies" {
  for_each           = local.policies
  source             = "../../iam/policy"
  policy_name        = each.key
  policy_path        = "/platform/"
  policy_description = each.value[0]
  policy_json        = each.value[1]
  tags               = var.tags
}

# Create a role with no access and the above permissions boundary. This serves two purposes:
# 1. It can be useful in rare circumstances when testing/validating IAM actions that can fail (a role with no access
#    should fail everything).
# 2. Some Security Hub compliance scans detect "dangerous" policies that permit too much ... unless those policies are
#    only used as permissions boundaries (e.g. KMS.1 scan). If a policy is unattached/unused, those scans generate
#    alerts, but if a policy is attached and only as a permissions boundary, it is silenced.
module "dummy_sandbox_bounded_role" {
  source      = "../../iam/role"
  role_path   = "/platform/"
  role_name   = "NoAccess"
  policy_arns = [module.policies["NoAccess"].policy_arn]
  # Anyone can assume it, they just can't do anything once they do:
  assume_role_principals          = [data.aws_caller_identity.current.account_id]
  permissions_boundary_policy_arn = module.policies["SandboxPermissionsBoundary"].policy_arn
}

output "iam_policies" {
  description = "A mapping between policy name and iam/policy module output objects"
  depends_on  = [module.policies] # Without this, terraform doesn't wait until they're all created
  value       = { for policy in values(module.policies) : policy.policy_name => policy }
}