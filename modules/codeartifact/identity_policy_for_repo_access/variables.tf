variable "repositories" {
  description = "ARNs for CodeArtifact repositories to which this policy should have access"
  type = object({
    pull = set(string)
    push = set(string)
  })
  default = {
    pull = []
    push = []
  }
}
