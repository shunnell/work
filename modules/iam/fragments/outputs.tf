output "kms_decrypt_restrictions" {
  value       = data.aws_iam_policy_document.kms_restrictions.minified_json
  description = "Fragment describing restrictions on KMS decryption actions; policies which contain kms:Decrypt* without this fragment will generate security findings"
}


output "tenant_ec2_restrictions" {
  value = module.ec2_restrictions.json
}

output "tenant_eks_restrictions" {
  value = data.aws_iam_policy_document.tenant_eks_restrictions.minified_json
}

output "iam_restrictions" {
  value = data.aws_iam_policy_document.iam_restrictions.minified_json
}

output "disabled_services_restrictions" {
  value = data.aws_iam_policy_document.general_services_restrictions.minified_json
}

output "tenant_iam_restrictions" {
  value = data.aws_iam_policy_document.tenant_iam_restrictions.minified_json
}

output "tenant_security_restrictions" {
  value = data.aws_iam_policy_document.tenant_security_restrictions.minified_json
}

output "tenant_development_permissions" {
  value       = data.aws_iam_policy_document.tenant_development_permissions.minified_json
  description = <<EOT
    Fragment describing permissions of actions tenant principals (Appropriate SSO users and tenant-created roles) are allowed to perform.
    **Note:** Do *NOT* attach this document to any IAM principal that is not also subject to the various tenant restrictions IAM documents exported by this module (e.g. via a permissions boundary or SCP).
    **Note:** These permissions are insufficient on their own to allow tenant principals to do most tasks. These permissions should generally be combined with a broader permissions policy (e.g. ReadOnlyAccess) to allow convenient use.
  EOT
}

output "zero_access" {
  description = "IAM policy document which disallows all actions on all resources, included for convenience"
  value       = data.aws_iam_policy_document.no_permissions.minified_json
}
