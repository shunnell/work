module "support_access_role" {
  source = "../../iam/role"

  # Values for api access
  # Granting s3 readonly access and ec2 readonly access to user,role and service which assuming this role in this account
  role_name              = "AwsSupportAccessRoleForManagingIncidents"
  assume_role_principals = ["support.amazonaws.com"]
  policy_arns = [
    "arn:aws:iam::aws:policy/AWSSupportAccess"
  ]
  tags = var.tags
}
