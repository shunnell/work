module "access_policy_fragments" {
  source = "../access_policy_fragments"
}

locals {
  # Use a dummy codeartifact ARN for something that will never exist ("fakeresource/" isn't a resource type) in order
  # to reduce the need for dynamic blocks and conditions below:
  dummy_repo = toset(["arn:aws:codeartifact:::fakeresource/"])
}

data "aws_iam_policy_document" "policy" {
  # Basic Access
  statement {
    sid       = module.access_policy_fragments.basic_access.Sid
    actions   = module.access_policy_fragments.basic_access.Action
    resources = ["*"]
  }
  # Pull
  statement {
    sid     = module.access_policy_fragments.pull.Sid
    actions = module.access_policy_fragments.pull.Action
    # Pull permissions should be given for anything you can pull, push. Rationale being that places
    # which can push images should be able to pull them (since that's usually CICD and images to be pushed might need
    # to be tested).
    resources = length(setunion(var.repositories.pull, var.repositories.push)) > 0 ? setunion(
    var.repositories.pull, var.repositories.push) : local.dummy_repo
  }
  # Push
  statement {
    sid     = module.access_policy_fragments.push.Sid
    actions = module.access_policy_fragments.push.Action
    resources = length(setunion(var.repositories.push)) > 0 ? setunion(
    var.repositories.push) : local.dummy_repo
  }
}
