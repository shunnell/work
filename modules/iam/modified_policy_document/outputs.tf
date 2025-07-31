output "json" {
  value       = data.aws_iam_policy_document.policy.minified_json
  description = "The modified, minified policy document JSON."
}

output "policy_length" {
  value       = local.policy_length
  description = "The length of `modified_policy`"
  precondition {
    condition     = local.policy_length <= var.max_length
    error_message = "Max length exceeded for combined policy"
  }
}

output "policy_statements" {
  description = "The list of 'statement' objects in the policy's underlying 'data.aws_iam_policy_document'"
  value       = data.aws_iam_policy_document.policy.statement
}