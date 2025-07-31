# Pass policies through a document so we can minify the JSON to avoid length limits:
module "policy" {
  source         = "../modified_policy_document"
  policies       = [var.policy_json]
  max_length     = 6144 # Max allowed AWS policy size
  require_effect = null
  require_sid    = false
}

resource "aws_iam_policy" "this" {
  name        = var.policy_name
  name_prefix = var.name_prefix
  path        = var.policy_path
  policy      = module.policy.json
  description = var.policy_description
  tags        = var.tags
}
