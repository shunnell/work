module "runner_cache_s3_bucket" {
  source = "../../s3"
  # Not using runner-fleet-name to try to stay within the aggressive 37chr prefix length limit:
  name_prefix               = "${var.tenant_name}-${var.runner_fleet_name_suffix}-runners-cache"
  tags                      = local.tags
  empty_bucket_when_deleted = true # Cache data doesn't need deletion confirmation.
  # Versioning and object lock are disabled for two reasons:
  # 1. GitLab runners don't, by default, work with object lock as they don't set the required headers. This could be
  #    changed via configuration if needed, but given that these buckets are ephemeral caches that seems like overkill.
  # 2. GitLab runner caches are high-volatility/high-object-overwrite-rate buckets, and storing old versions may add
  #    unexpected costs. This can be reassessed if history is requested for these buckets in the future.
  record_history = false
  object_lock    = false
  policy_stanzas = {
    "AllowGitlabRunnerCacheAccess" = {
      principals = { AWS = [module.runner_iam_role.iam_role_arn] }
      actions    = ["s3:*"]
    }
  }
}
