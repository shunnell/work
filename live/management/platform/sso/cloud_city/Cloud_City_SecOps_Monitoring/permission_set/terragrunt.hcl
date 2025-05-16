include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "sso_resource" {
  path = "${get_repo_root()}/management/platform/sso/utilities/sso_resource.hcl"
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//iam/sso_permission_set"
}

inputs = {
  permission_set_name = "Cloud_City_ExternalSecurityUsers"
  description         = "Cloud City External Security Users' Permission Set (read-only permissions for use by CST security stakeholders, e.g. CIRT, DS Blue Team, ISSO)"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSSecurityHubReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSConfigUserAccess",
    "arn:aws:iam::aws:policy/AmazonGuardDutyReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonMacieReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonInspector2ReadOnlyAccess",
    # Legacy/deprecated old Inspector product, but granting read-only to security folks doesn't hurt:
    "arn:aws:iam::aws:policy/AmazonInspectorReadOnlyAccess",
  ]
}