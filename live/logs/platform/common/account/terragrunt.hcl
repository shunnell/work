include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "baseline" {
  path = "${get_repo_root()}/_envcommon/platform/common/account/monitoring_baseline.hcl"
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//common/account/"
}

inputs = {
  # We can't share things via OAM with ourselves; the CloudFormation suggested for OAM sharing by AWS is very, very
  # paranoid about the risk of creating "loops". Given how many redundant places AWS tries to prevent this, let's not
  # find out what happens if we use AWS's newest and least-documented CloudWatch API to implement a recursive system,
  # mmkay?
  oam_sink_id               = null
  oam_shared_resource_types = []
}
