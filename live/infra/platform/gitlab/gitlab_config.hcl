locals {
  service_account_name = "gitlab"
  prefix               = "dos-cloudcity-gitlab"
  suffix               = "server"
  namespace            = "gitlab-${local.suffix}"

  ## Bucket names for GitLab server
  bucket_names = [
    "${local.prefix}-artifacts-${local.suffix}",
    "${local.prefix}-ci-secure-files-${local.suffix}",
    "${local.prefix}-dependency-proxy-${local.suffix}",
    "${local.prefix}-lfs-${local.suffix}",
    "${local.prefix}-mr-diffs-${local.suffix}",
    "${local.prefix}-registry-${local.suffix}",
    "${local.prefix}-packages-${local.suffix}",
    "${local.prefix}-pages-${local.suffix}",
    "${local.prefix}-terraform-state-${local.suffix}",
    "${local.prefix}-uploads-${local.suffix}",
    "${local.prefix}-backup-${local.suffix}",
    "${local.prefix}-tmp-backup-${local.suffix}"
  ]

  tags = {
    purpose = "GitLab"
  }
}

inputs = {
  # TODO: Cert module
  acm_cert_arn = "arn:aws:acm:us-east-1:381492150796:certificate/4e2d8079-0646-4976-bbfb-36d06688ae8d"
  namespace    = local.namespace
  tags         = local.tags
}
