variable "pull_organizational_units" {
  description = "The organizational units which will be granted pull access to this registry (push should be granted to account-local principals separately and not managed by this module)"
  type        = set(string)
}

variable "pull_through_organizational_units" {
  description = "The organizational units which will be granted pull through access to this registry (push should be granted to account-local principals separately and not managed by this module)"
  type        = set(string)
}
