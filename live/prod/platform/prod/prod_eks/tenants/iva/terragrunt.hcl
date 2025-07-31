include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "k8s" {
  path = "${get_path_to_repo_root()}/_envcommon/platform/eks/k8s.hcl"
}

include "tenant" {
  path = "${get_path_to_repo_root()}/_envcommon/platform/eks/cluster_tenant.hcl"
}

dependency "bootstrap" {
  config_path = "../../bootstrap"
  mock_outputs = {
    root_domain_name = ""
  }
}

inputs = {
  tenant_name         = "iva"
  tenant_domain_names = { "cloud-city" = "iva.${dependency.bootstrap.outputs.root_domain_name}" }
}
