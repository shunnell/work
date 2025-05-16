data "aws_region" "current" {}

locals {
  repo_url = "https://gitlab.cloud-city/cloud-city/platform/gitops/kubernetes.git"
}

resource "kubernetes_manifest" "kubernetes_repo_application" {
  depends_on = [kubernetes_manifest.repo_secret]
  manifest = yamldecode(<<-YAML
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: ccp-kubernetes-repo
      namespace: "${var.argocd_namespace}"
    spec:
      project: default
      source:
        repoURL: "${local.repo_url}"
        targetRevision: HEAD
        path: "_base/_infrastructure"
      destination:
        server: https://kubernetes.default.svc
      syncPolicy:
        syncOptions:
          - ServerSideApply=true
        automated:
          prune: true
          selfHeal: true
  YAML
  )
}
