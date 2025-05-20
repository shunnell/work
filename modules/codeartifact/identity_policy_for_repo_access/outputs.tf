output "policy" {
  description = "an aws_iam_policy_document object"
  value       = data.aws_iam_policy_document.policy
}