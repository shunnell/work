include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "gitlab_vpc" {
  config_path = "../../network/gitlab_vpc"
  mock_outputs = {
    vpc_id = ""
  }
}

dependency "vpn_vpc" {
  config_path = "../../network/vpn_vpc"
  mock_outputs = {
    vpc_id = ""
  }
}

dependency "admin_vpc" {
  config_path = "../../admin/admin_vpc/vpc"
  mock_outputs = {
    vpc_id = ""
  }
}

# TODO this is backwards and temporary, pending a better multi-acccount DNS solution: we depend on the OPR argocd EKS
#   instance here to ensure its hostname is in the .cloud-city DNS zone. In the future, DNS updating will be done as
#   part of EKS resource deployments and automatically propagated into the appropriate DNS, but that's not ready yet.
dependency "opr_dev_argocd" {
  config_path = "${get_repo_root()}/opr/platform/dev/dev_eks/bootstrap"
  mock_outputs = {
    argocd_server_endpoint = { load_balancer_hostname = "" }
  }
}

dependency "opr_staging_argocd" {
  config_path = "${get_repo_root()}/opr/platform/staging/staging_eks/bootstrap"
  mock_outputs = {
    argocd_server_endpoint = { load_balancer_hostname = "" }
  }
}

dependency "visas_dev_argocd" {
  config_path = "${get_repo_root()}/visas/platform/dev/dev_eks/bootstrap"
  mock_outputs = {
    argocd_server_endpoint = { load_balancer_hostname = "" }
  }
}

dependency "pass_dev_argocd" {
  config_path = "${get_repo_root()}/pass/platform/dev/dev_eks/bootstrap"
  mock_outputs = {
    argocd_server_endpoint = { load_balancer_hostname = "" }
  }
}

dependency "ocam_dev_argocd" {
  config_path = "${get_repo_root()}/ocam/platform/dev/dev_eks/bootstrap"
  mock_outputs = {
    argocd_server_endpoint = { load_balancer_hostname = "" }
  }
}

terraform {
  source = "${get_repo_root()}/../modules//dns/recordset"
}

inputs = {
  domain      = "cloud-city"
  description = "Interim private hosted zone for cloud city resources"
  a_records = {
    # TODO once GitLab is on EKS these will not be managed here and should instead be set up by ExternalDNS in EKS:
    gitlab     = ["172.16.1.103"]
    "*.gitlab" = ["172.16.1.103"]
  }
  cname_records = {
    "argocd.opr-dev"     = dependency.opr_dev_argocd.outputs.argocd_server_endpoint.load_balancer_hostname
    "argocd.opr-staging" = dependency.opr_staging_argocd.outputs.argocd_server_endpoint.load_balancer_hostname
    "argocd.visas-dev"   = dependency.visas_dev_argocd.outputs.argocd_server_endpoint.load_balancer_hostname
    "argocd.pass-dev"    = dependency.pass_dev_argocd.outputs.argocd_server_endpoint.load_balancer_hostname
    "argocd.ocam-dev"    = dependency.ocam_dev_argocd.outputs.argocd_server_endpoint.load_balancer_hostname
  }
  vpc_associations = [
    dependency.gitlab_vpc.outputs.vpc_id,
    dependency.vpn_vpc.outputs.vpc_id,
    dependency.admin_vpc.outputs.vpc_id,
  ]
}