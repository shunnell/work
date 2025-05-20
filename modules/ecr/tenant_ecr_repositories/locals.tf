locals {
  repository_path_prefixes = [
    # TODO legacy breakage: remove once tenants are all publishing/using images in the cloud-city/tenant-name/$image
    #    hierarchy. Tenants should stop doing this and migrate to the new path, after which old images in those paths
    #    can be removed and this rule removed:
    "${var.tenant_name}/*",
    # TODO legacy breakage; remove once tenants are not publishing to an image at the root of their tenant name. This is
    #   an antipattern that should never have been allowed; only a few tenants are doing it and should stop, after which
    #   old images in those paths can be deleted and this rule removed:
    "cloud-city/${var.tenant_name}",
    "cloud-city/${var.tenant_name}/*",
  ]
  tenant_repository_prefixes = setunion(var.legacy_ecr_repository_names_to_be_migrated, local.repository_path_prefixes)
  per_repo_pull_policy       = length(module.per_repo_pull_policy) > 0 ? module.per_repo_pull_policy[0].json : "{}"
  action_types               = toset(["pull", "push", "view"])
  policy_outputs = { for t in local.action_types : t => {
    arn  = module.identity_policies[t].policy_arn
    path = module.identity_policies[t].policy_path,
    name = module.identity_policies[t].policy_name,
    json = module.identity_policy_documents[t].json
  } }
}

module "identity_policy_documents" {
  for_each     = local.action_types
  source       = "../access_policy_document"
  action       = each.key
  repositories = local.tenant_repository_prefixes
}

# TODO this entire invocation should be removed if or when tenants are restricted to only publish images from within
#   CI/CD. Even if that doesn't eventually happen, the legacy paths below should also be cleaned up regardless:
module "per_repo_pull_policy" {
  count      = length(var.aws_accounts_with_pull_access) > 0 ? 1 : 0
  source     = "../access_policy_document"
  action     = "pull"
  principals = [for account in var.aws_accounts_with_pull_access : "arn:aws:iam::${account}:root"]
}
