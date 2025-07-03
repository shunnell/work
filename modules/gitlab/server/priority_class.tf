resource "kubernetes_priority_class" "this" {
  metadata {
    name = "${var.release_name}-gitaly"
  }
  value          = 1000000
  global_default = false
  description    = "GitLab Gitaly priority class"
}
