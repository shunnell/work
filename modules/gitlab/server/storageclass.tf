resource "kubernetes_storage_class" "gitaly_retain" {
  metadata {
    name = "gitaly-${var.release_name}"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = false
    }
  }
  storage_provisioner    = "ebs.csi.aws.com"
  allow_volume_expansion = true
  reclaim_policy         = "Retain"
  parameters = {
    encrypted                   = "true"
    type                        = "gp3"
    "csi.storage.k8s.io/fstype" = "ext4"
    tagSpecification_1          = "eks_backup=true"
  }
}

# https://letsdocloud.com/2020/09/how-to-reuse-a-persistentvolume-pv-in-kubernetes/
# https://docs.aws.amazon.com/ebs/latest/userguide/ebs-volume-types.html
# https://kubernetes.io/docs/concepts/storage/persistent-volumes/#retroactive-default-storageclass-assignment
