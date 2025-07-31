variable "repositories" {
  description = "ARNs for CodeArtifact repositories to which this policy should have access"
  type = object({
    pull = optional(set(string), [])
    push = optional(set(string), [])
  })
  default = {
    pull = []
    push = []
  }
}
