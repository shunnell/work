resource "kubernetes_priority_class" "this" {
  metadata {
    name = "gitlab-gitaly"
  }
  value          = 1000000
  global_default = false
  description    = "GitLab Gitaly priority class"
  depends_on     = [kubernetes_namespace.gitlab_namespace]
}