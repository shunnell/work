output "backup_plan_id" {
  description = "The ID of the AWS Backup plan created for EKS EBS volumes"
  value       = aws_backup_plan.eks_ebs_plan.id
}

output "backup_selection_id" {
  description = "The ID of the AWS Backup selection associated with the backup plan"
  value       = aws_backup_selection.eks_ebs_selection.id
}

output "backup_role_arn" {
  description = "The ARN of the existing IAM role used for AWS Backup operations"
  value       = data.aws_iam_role.existing_backup_role.arn
}

