data "aws_secretsmanager_secret_version" "gitlab_secret" {
  secret_id = var.gitlab_secret_id
  lifecycle {
    postcondition {
      condition     = can(jsondecode(self.secret_string)["oauth_token"])
      error_message = "GitLab secret ${var.gitlab_secret_id} doesn't have an OAuth token; one should be externally created. 'oauth_token'"
    }
    postcondition {
      condition     = can(jsondecode(self.secret_string)["rails_secret"])
      error_message = "GitLab secret ${var.gitlab_secret_id} doesn't have a rails secret; one should be externally created. 'rails_secret'"
    }
    postcondition {
      condition     = can(jsondecode(self.secret_string)["idp_cert_fingerprint"])
      error_message = "GitLab secret ${var.gitlab_secret_id} doesn't have a rails secret; one should be externally created. 'idp_cert_fingerprint'"
    }
  }
}

locals {
  irsa_name            = "gitlab-${var.irsa_name}"
  rds_ext_secret       = "gitlab-aws-${var.rds_secret}"
  redis_ext_secret     = "gitlab-aws-${var.redis_secret}"
  custom_image_repo    = "${var.image_registry_root}/gitlab/gitlab-org/build/cng"
  oauth_token          = sensitive(jsondecode(data.aws_secretsmanager_secret_version.gitlab_secret.secret_string)["oauth_token"])
  rails_secret         = sensitive(jsondecode(data.aws_secretsmanager_secret_version.gitlab_secret.secret_string)["rails_secret"])
  idp_cert_fingerprint = sensitive(jsondecode(data.aws_secretsmanager_secret_version.gitlab_secret.secret_string)["idp_cert_fingerprint"])
  tags = merge(
    {
      # For human visibility:
      "gitlab" = var.release_name
      # For AWS association with the parent EKS, or for human searches for 'all things related to this cluster':
      "eks:cluster-name" : var.cluster_name
    },
    var.tags
  )
}
