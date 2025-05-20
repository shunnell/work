terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
  }
}

resource "helm_release" "this" {
  chart     = var.chart
  name      = var.release_name
  namespace = var.namespace
  version   = var.chart_version

  # Default the protocol to oci:// to facilitate easier access to Helm charts stored as Docker images in ECR:
  repository           = length(regexall("^\\w+://.*$", var.repository)) > 0 ? var.repository : "oci://${var.repository}"
  create_namespace     = var.create_namespace
  atomic               = var.atomic
  cleanup_on_fail      = var.cleanup_on_fail
  dependency_update    = var.dependency_update
  force_update         = var.force_update
  max_history          = var.max_history
  recreate_pods        = var.recreate_pods
  replace              = var.replace
  repository_ca_file   = var.repository_ca_file
  repository_cert_file = var.repository_cert_file
  repository_key_file  = var.repository_key_file
  repository_password  = var.repository_password
  repository_username  = var.repository_username
  skip_crds            = var.skip_crds
  timeout              = var.timeout
  upgrade_install      = var.upgrade_install

  dynamic "set" {
    for_each = var.set
    content {
      name  = set.key
      value = set.value
    }
  }

  dynamic "set_list" {
    for_each = var.set_list
    content {
      name  = set_list.key
      value = set_list.value
    }
  }

  dynamic "set_sensitive" {
    for_each = var.set_sensitive
    content {
      name  = set_sensitive.key
      value = set_sensitive.value
    }
  }

  values = var.values

  lint          = true
  wait_for_jobs = true
  # provenance not available
  verify = false
}
