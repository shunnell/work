resource "kubernetes_namespace" "gitlab_runner_ns" {
  metadata {
    name = "gitlab-runner"
  }
}

resource "helm_release" "gitlab_runner" {
  name       = "gitlab-runner"
  repository = "https://charts.gitlab.io"
  chart      = "gitlab-runner"
  namespace  = kubernetes_namespace.gitlab_runner_ns.metadata[0].name
  version    = "0.68.1"
  # Docker-certs empty dir below added for OPR to use DIND; long term container build plans should obsolete this.
  values = [
    <<EOF
gitlabUrl: https://gitlab.cloud-city/
runnerToken: glrt-X88oXJZvs_VdkhThd6Vu
certsSecretName: gitlab-runner-certs
runners:
  config: |
    [[runners]]
      name = "k8s-runner"
      url = "https://gitlab.cloud-city/"
      executor = "kubernetes"
      tls-skip-verify = true   # Add this line to skip SSL verification
      [runners.kubernetes]
        image = "gitlab/gitlab-runner:latest"
        namespace = "${kubernetes_namespace.gitlab_runner_ns.metadata[0].name}"
        serviceAccountName = "${kubernetes_service_account.gitlab_runner_sa.metadata[0].name}"
        privileged = true
      [[runners.kubernetes.volumes.secret]]
        name = "${kubernetes_secret.gitlab_runner_certs.metadata[0].name}"
        mount_path = "/etc/gitlab-runner/certs/"
      [[runners.kubernetes.volumes.empty_dir]]
        name = "docker-certs"
        mount_path = "/certs/client"
        medium = "Memory"
      [runners.cache]
        Type = "s3"
        Path = "runners"
        Shared = true
        [runners.cache.s3]
          ServerAddress = "s3.amazonaws.com"
          BucketName = "${var.cache_s3_bucket_name}"
          BucketLocation= "us-east-1"
EOF
  ]
}

resource "kubernetes_role" "gitlab_runner_role" {
  metadata {
    name      = "gitlab-runner-role"
    namespace = kubernetes_namespace.gitlab_runner_ns.metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "pods/exec", "pods/log", "pods/attach", "secrets"]
    verbs      = ["get", "list", "watch", "create", "delete", "patch", "update"]
  }
}

resource "kubernetes_service_account" "gitlab_runner_sa" {
  metadata {
    name      =  "gitlab-runner-sa"
    namespace = kubernetes_namespace.gitlab_runner_ns.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = var.runner_service_account_role_arn
    }
  }
}

resource "kubernetes_role_binding" "gitlab_runner_rolebinding" {
  metadata {
    name      = "gitlab-runner-rolebinding"
    namespace = kubernetes_namespace.gitlab_runner_ns.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.gitlab_runner_sa.metadata[0].name
    namespace = kubernetes_namespace.gitlab_runner_ns.metadata[0].name
  }

  role_ref {
    kind      = "Role"
    name      = kubernetes_role.gitlab_runner_role.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_secret" "gitlab_runner_certs" {
  metadata {
    name      = "gitlab-runner-certs"
    namespace = kubernetes_namespace.gitlab_runner_ns.metadata[0].name
  }

  data = {
    # The data in that file was not imported from gitlab-iac when migrating, as both "fullchain" files in the iac repo
    # created drift. Instead, this data was imported from production on 1/13/2025.
    "gitlab.cloud-city.crt" = file("${path.module}/certs/gitlab-fullchain-cert.crt")
  }

  type = "Opaque"
}
