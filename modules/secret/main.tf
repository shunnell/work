resource "aws_secretsmanager_secret" "this" {
  name                    = var.name
  name_prefix             = var.name_prefix
  description             = var.description
  tags                    = var.tags
  recovery_window_in_days = 10 # TODO update this if security compliance controls require a specific value.
}

# Manage either of two secrets, since the ignore_changes field has to be a static string and can't be conditioned on
# a variable.
resource "aws_secretsmanager_secret_version" "secret_fully_managed" {
  count         = var.ignore_changes_to_secret_value ? 0 : 1
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = var.value
}

resource "aws_secretsmanager_secret_version" "secret_externally_managed" {
  count         = var.ignore_changes_to_secret_value ? 1 : 0
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = var.value
  lifecycle {
    ignore_changes = [secret_string]
  }
}

data "aws_secretsmanager_secret_version" "current_fully_managed" {
  count         = var.ignore_changes_to_secret_value ? 0 : 1
  secret_id     = aws_secretsmanager_secret.this.id
  version_stage = "AWSCURRENT" # technically, the default
  depends_on = [
    aws_secretsmanager_secret_version.secret_fully_managed
  ]
}

data "aws_secretsmanager_secret_version" "current_externally_managed" {
  count         = var.ignore_changes_to_secret_value ? 1 : 0
  secret_id     = aws_secretsmanager_secret.this.id
  version_stage = "AWSCURRENT" # technically, the default
  depends_on = [
    aws_secretsmanager_secret_version.secret_externally_managed
  ]
}
