resource "kubernetes_manifest" "ebs_sc" {
  manifest = yamldecode(file("resources/storageclass-default.yaml"))
}

resource "kubernetes_manifest" "ebs_sc_retain" {
  manifest = yamldecode(file("resources/storageclass-retain.yaml"))
}
