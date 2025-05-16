resource "kubernetes_manifest" "ebs_sc" {
  manifest = yamldecode(file("storageclass.yaml"))
}

resource "kubernetes_manifest" "ebs_sc_retain" {
  manifest = yamldecode(file("data-retention-sc.yaml"))
}

