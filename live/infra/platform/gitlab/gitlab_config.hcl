locals {
  namespace            = "gitlab"
  service_account_name = "gitlab"
  prefix               = "dos-cloudcity-gitlab"
  tags = {
    purpose = "GitLab"
  }
}

inputs = {
  tags = local.tags
}
