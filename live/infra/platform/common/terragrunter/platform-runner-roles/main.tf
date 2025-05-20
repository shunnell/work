variable "role_name" {
  description = "Name of the IAM Role to search for"
  type        = string
}

data "aws_iam_roles" "roles" {
  name_regex = var.role_name
}

output "arns" {
  description = "ARN of the retrieved IAM Roles"
  value       = tolist(data.aws_iam_roles.roles.arns)
}
