locals {
  # NB: Not using \w+ because some AWS services have dashes (-) in the names:
  service_principal_regex = "^([a-z0-9_-]+[.])+amazonaws[.]com$"
  # A regex is cleaner than arn_parse here: we only allow certain kinds of ARNs (sts or iam) and don't allow wildcards
  # in the descriptor either:
  aws_principal_regex = "^arn:aws:(sts|iam)::\\d+:[^*]+$"
}