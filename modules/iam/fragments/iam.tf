locals {
  sandbox_boundary = "arn:aws:iam::*:policy/platform/SandboxPermissionsBoundary"
  sandbox_roles = [
    "arn:aws:iam::*:role/sandbox/*",
    "arn:aws:iam::*:role/sandbox-*",
  ]
  sandbox_policies = [
    "arn:aws:iam::*:policy/sandbox/*",
  ]
  sensitive_resources = [
    local.sandbox_boundary,
    "arn:aws:iam::*:role/platform/terragrunter",
    "arn:aws:iam::*:role/terragrunter",
    "arn:aws:iam::*:policy/platform/terragrunter",
    "arn:aws:iam::*:policy/terragrunter",
    "arn:aws:iam::*:role/aws-controltower-*",
    "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/*",
  ]
  # Nobody, not even admins, should be able to perform these IAM actions:
  globally_forbidden_iam_actions = [
    "iam:AddUserToGroup",
    "iam:AttachGroupPolicy",
    "iam:AttachUserPolicy",
    "iam:CreateAccessKey",
    "iam:CreateAccessKey",
    "iam:CreateGroup",
    "iam:CreateVirtualMFADevice",
    "iam:CreateUser",
    "iam:DeleteVirtualMFADevice",
    "iam:DisableOrganizationsRootCredentialsManagement",
    "iam:DisableOrganizationsRootSessions",
    "iam:EnableOrganizationsRootCredentialsManagement",
    "iam:EnableOrganizationsRootSessions",
    "iam:PutGroupPolicy",
    "iam:PutUserPolicy",
    "iam:ResyncMFADevice",
    "iam:TagMFADevice",
    "iam:TagUser",
    "iam:UntagMFADevice",
    "iam:UpdateGroup",
    "iam:UpdateUser",
    "iam:Upload*",
  ]
  # Admins can perform these, but tenants cannot:
  tenant_forbidden_iam_actions = [
    "iam:AddClientIDToOpenIDConnectProvider",
    "iam:ChangePassword",
    "iam:CreateAccountAlias",
    "iam:CreateOpenIDConnectProvider",
    "iam:CreateSAMLProvider",
    "iam:DeactivateMFADevice",
    "iam:DeleteAccessKey",
    "iam:DeleteAccountAlias",
    "iam:DeleteAccountPasswordPolicy",
    "iam:DeleteGroup",
    "iam:DeleteGroupPolicy",
    "iam:DeleteOpenIDConnectProvider",
    "iam:DeleteRolePermissionsBoundary",
    "iam:DeleteSAMLProvider",
    "iam:DeleteUser",
    "iam:DeleteUserPolicy",
    "iam:DetachUserPolicy",
    "iam:DetachGroupPolicy",
    "iam:EnableMFADevice",
    "iam:RemoveClientIDFromOpenIDConnectProvider",
    "iam:RemoveUserFromGroup",
    "iam:ResetServiceSpecificCredential",
    "iam:PutRolePermissionsBoundary",
    "iam:SetSecurityTokenServicePreferences",
    "iam:SetSTSRegionalEndpointStatus",
    "iam:TagOpenIDConnectProvider",
    "iam:TagSAMLProvider",
    "iam:UntagOpenIDConnectProvider",
    "iam:UntagSAMLProvider",
    "iam:UntagUser",
    "iam:UpdateAccountEmailAddress",
    "iam:UpdateAccountName",
    "iam:UpdateAccountPasswordPolicy",
    "iam:UpdateOpenIDConnectProviderThumbprint",
    "iam:UpdateSAMLProvider",
    "iam:UploadSigningCertificate",
  ]
}

data "aws_iam_policy_document" "iam_restrictions" {
  statement {
    sid       = "DenyForbiddenIAMModifications"
    effect    = "Deny"
    actions   = local.globally_forbidden_iam_actions
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "tenant_iam_restrictions" {
  statement {
    sid    = "DenyAccessToSensitiveEntities"
    effect = "Deny"
    actions = [
      "sts:AssumeRole",
      "iam:Update*",
      "iam:Delete*",
      "iam:Put*",
      # OPR red team identified the fact that the permissions boundary and other admin roles can even be enumerated as
      # a minor vulnerability, so lock that out:
      "iam:Describe*",
      "iam:Get*",
    ]
    resources = local.sensitive_resources
  }
  statement {
    sid       = "DenyForbiddenIAMModifications"
    effect    = "Deny"
    actions   = local.tenant_forbidden_iam_actions
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "tenant_iam_permissions" {
  # Most statements in the _permissions data vars (rather than the _restriction) data vars are "Allow"-only. This is
  # the rare exception which is a "Deny", written here since SCPs can't use NotResource/not_resources.
  statement {
    # NOTE: Never, *ever* add the ability to create or modify roles to this statement. Role alternation is controlled
    # by the PermitRoleModifyWithBoundary statement instead, conditioned on the permissions boundary. Adding it here
    # would open a huge security hole.
    sid    = "AllowIAMToTenantManagedEntities"
    effect = "Allow"
    # Apply these permissions to sandbox policies, roles, and instance profiles. Note that this statement is a bit
    # ugly in that actions aren't paired with only the resources the affect. However, this is harmless and saves very
    # precious quota/document-size space in the already-near-the-limit sandbox SSO policy and permissions boundary
    # sizes:
    resources = concat(
      local.sandbox_policies,
      local.sandbox_roles,
      # More info: https://maximaavem.medium.com/adventures-with-boundary-policies-in-aws-iam-31734715362b
      ["arn:aws:iam::*:instance-profile/*"]
    )
    actions = [
      "sts:AssumeRole", # Tenants can assume into sandbox roles
      # Tenants can tag/untag things:
      "iam:Tag*",
      "iam:Untag*",
      "iam:PassRole", # Tenants can PassRole on sandbox roles only (PassRole should NEVERs be permitted for SSO roles).
      # Tenants can delete roles:
      # Note the missing condition: deletion doesn't "see" the permissions boundary via the variable, so we permit
      # deletion more broadly just based on role name/path, rather than testing whether the perms boundary is attached.
      "iam:DeleteRole",
      "iam:DeleteServiceLinkedRole",
      # Tenants can modify policies in the sandbox prefixes:
      "iam:SetDefaultPolicyVersion",
      "iam:CreatePolicy*",
      "iam:DeletePolicy*",
      # Tenants can mess with instance profiles:
      "iam:CreateInstanceProfile",
      # TODO restrict what roles they can add. There's no condition for that, so we might need to release some default
      #   instance-profile roles for tenant use which are appropriately restricted. Alternatively, there might be a
      #   way to restrict actions taken by instance profiles more generally via SCP-specific EC2-specific keys?
      "iam:AddRoleToInstanceProfile",
      "iam:DeleteInstanceProfile",
      # Tenants can modify sandbox policies:
      "iam:CreatePolicyVersion",
      "iam:CreatePolicy",
      "iam:DeletePolicyVersion",
      "iam:TagPolicy",
      "iam:UntagPolicy",
      "iam:DeletePolicy",
    ]
  }
  statement {
    # Note that some read permissions are denied for security reasons via SCPs using the _restrictions documents above.
    sid    = "PermitIAMReadBroadly"
    effect = "Allow"
    actions = [
      "iam:List*",
      "iam:Describe*",
      "iam:Get*",
      # Generate* only includes access reports/read-only stuff. If this is found to be an info leak vulnerability it
      # can be removed, most folks use it rarely and only for debugging:
      "iam:Generate*",
    ]
    resources = ["*"]
  }
  statement {
    # TODO this can probably be an SCP deny without the resources param:
    sid    = "PermitRoleModifyWithBoundary"
    effect = "Allow"
    # Only roles within the sandbox scope may be modified by tenants.
    # NOTE: If adding an action to this statement, first check whether it supports the iam:PermissionsBoundary condition
    # key in www.awsiamactions.io.
    condition {
      test     = "ArnLike"
      values   = [local.sandbox_boundary]
      variable = "iam:PermissionsBoundary"
    }
    actions = [
      "iam:CreateRole",
      "iam:*RolePolicy",
      "iam:UpdateAssumeRolePolicy",
      "iam:UpdateRole*", # Includes UpdateRole and UpdateRoleDescription
      # Tenants can add the sandbox permissions boundary to roles that don't have it, but can't remove that boundary.
      # If they need to delete an old permissions boundary and attach the new one, they'll have to ask platform admins
      # to do that for them:
      # TODO does this test on the old boundary attached to a role, or the new one?
      "iam:PutRolePermissionsBoundary",
    ]
    resources = local.sandbox_roles

  }
}
