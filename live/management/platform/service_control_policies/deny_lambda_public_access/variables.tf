variable "organizational_unit" {
  description = "ID of the Root Organization"
  type        = string
}

variable "lambda_security_policy_tags" {
  description = "Tags to apply to the Lambda security restrictions SCP"
  type        = map(string)
  default = {
    purpose = "Deny Lambdas creation or modification with Function URLs or without a VPC"
  }
}