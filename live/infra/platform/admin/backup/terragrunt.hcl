terraform {
  source = "${get_repo_root()}/../modules//backup"
}

inputs = {
  existing_backup_role_name = "AWSBackupDefaultServiceRole"
  backup_plan_name          = "eks-ebs-backup-plan"
  backup_rule_name          = "daily-ebs-backup"
  schedule_frequency        = "daily" # Options: hourly, daily, weekly, monthly
  start_window              = 60
  completion_window         = 120
  delete_after_days         = 30

  tags = {
  }

  recovery_point_tags = {
    BackupType = "daily"
  }

  selection_tags = {
    eks_backup = "true"
  }
}
