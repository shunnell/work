resource "kubernetes_namespace" "fleet_namespace" {
  metadata {
    name = local.runner_fleet_name
  }
}

resource "kubernetes_storage_class" "runner_ebs_sc" {
  metadata {
    name = "${local.runner_fleet_name}-fast-ephemeral"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = false
    }
  }
  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Delete"
  parameters = {
    # https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/parameters.md
    type                        = "gp3"
    "csi.storage.k8s.io/fstype" = "ext4"
    # Since build volumes can be quite small, allow the controller to "round up" to meet our IOPS/throughput targets.
    allowAutoIOPSPerGBIncrease = true
    encrypted                  = true
    # Since build volumes are short-lived, we can default to providing a fairly large amount of performance without
    # risking significant costs.
    # NB: These values assume that volumes are at least 6GB, a limitation that we enforce via the validation of the
    # scratch_space_size_gb variable.
    iopsPerGB          = 3000
    throughput         = 250
    tagSpecification_1 = "gitlab_runner_fleet_name=${local.runner_fleet_name}"
  }
}

resource "kubernetes_secret" "gitlab_certificate" {
  metadata {
    name      = local.secret_name
    namespace = kubernetes_namespace.fleet_namespace.metadata[0].name
  }
  data = {
    "${var.gitlab_mothership_domain}.crt" = var.gitlab_certificate
  }
}
