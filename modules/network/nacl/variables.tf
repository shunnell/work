variable "vpc_id" {
  type    = string
  default = ""
}

variable "ingress_rules" {
  type = list(object({
    rule_no    = number
    action     = string
    from_port  = number
    to_port    = number
    protocol   = string
    cidr_block = string
  }))
}

variable "egress_rules" {
  type = list(object({
    rule_no    = number
    action     = string
    from_port  = number
    to_port    = number
    protocol   = string
    cidr_block = string
  }))
}

variable "tags" {
  type    = map(string)
  default = {}
}
