data "aws_secretsmanager_secret_version" "gitlab_secret" {
  secret_id = var.gitlab_secret_id
  lifecycle {
    postcondition {
      condition     = can(jsondecode(self.secret_string)[local.runner_fleet_name]["token"])
      error_message = "GitLab secret ${var.gitlab_secret_id} doesn't have a token for this runner fleet name; one should be externally created"
    }
  }
}

locals {
  builds_dir = "/builds"
  tmp_dir    = "/tmp"
  # Silly hack: we don't want to accidentally provision multiple runner clusters with the same join token, that would
  # cause really confusing intermittent failures in GitLab. So we create an account-wide resource (IRSA) with a
  # name that's a function of the join token so that attempts to create other instances of this module with the same
  # token will fail with "already exists". There's nothing special about using IRSA for this, it just happens to be there.
  runner_irsa_name  = "gitlab-runners-${substr(sha256(local.join_token), 0, 32)}"
  runner_fleet_name = "gitlab-runners-${var.tenant_name}-${var.runner_fleet_name_suffix}"
  join_token        = sensitive(jsondecode(data.aws_secretsmanager_secret_version.gitlab_secret.secret_string)[local.runner_fleet_name]["token"])
  secret_name       = "gitlab-cloud-city"
  rbac_read         = "list,get,watch"
  rbac_write        = "create,update,patch,delete"
  tags = merge(
    {
      # For human visibility:
      "gitlab-runner-fleet" = local.runner_fleet_name
      # For AWS association with the parent EKS, or for human searches for 'all things related to this cluster':
      "eks:cluster-name" : var.cluster_name
    },
    var.tags
  )
  # NB: Not using \w+ because some AWS services have dashes (-) in the names:
  service_principal_regex = "^([a-z0-9_-]+[.])+amazonaws[.]com$"
  # A regex is cleaner than arn_parse here: we only allow certain kinds of ARNs (sts or iam) and don't allow wildcards
  # in the descriptor either:
  aws_principal_regex = "^arn:aws:(sts|iam)::\\d+:[^*]+$"
}
