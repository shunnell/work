# Create internal policies for supplied JSON documents. Not using inline policies for consistency/aesthetic reasons:
# it's easier to debug and view role behavior in the AWS UI if all permissions are attached in one tab rather than
# some being inline and others being attached. If this causes problems (e.g. due to policy/attachment count quotas),
# we can switch to inline policies instead.
module "manual_policies" {
  for_each    = var.policy_json_documents
  source      = "../policy"
  name_prefix = each.key
  policy_json = each.value
  tags        = merge(var.tags, { "CloudCity/role" = aws_iam_role.this.name })
}

# These explicit attachments seem redundant with the aws_iam_role_policies_exclusive resource below, which will also
# ensure the same policies are attached to the role. However, the aws_iam_role_policies_exclusive resource does not
# detach policies when a resource is destroyed, leading to errors like "cannot delete a policy attached to resources"
# when things are removed. To get around those errors while still retaining the benefits of
# aws_iam_role_policies_exclusive (no external attachments allowed), we declare the attachments explicitly as well,
# since the destruction of aws_iam_role_policy_attachment *does* detach a policy.
resource "aws_iam_role_policy_attachment" "attachments_manual" {
  for_each   = var.policy_json_documents
  role       = aws_iam_role.this.name
  policy_arn = module.manual_policies[each.key].policy_arn
}

resource "aws_iam_role_policy_attachment" "attachments_external" {
  count      = length(var.policy_arns) # Using a set here fails for some reason
  role       = aws_iam_role.this.name
  policy_arn = var.policy_arns[count.index]
}

# Rather than using only aws_iam_role_policy_attachment, we force the attached and inline policy lists to be
# *exactly* what we specify. This prevents a common and sneaky source of drift and unexpected access wherein
# externally-attached role policies aren't automatically removed by Terraform. We want to fully manage
# everything about the role in this module. If you need to manage a role with inline policies or external attachments
# (e.g. you're modifying an AWS-supplied role), a) think hard about your choices and consider a data variable
# or state import, and b) if you really need that use an aws_iam_role resource directly instead of using this module.
resource "aws_iam_role_policy_attachments_exclusive" "policies" {
  depends_on  = [aws_iam_role_policy_attachment.attachments_external, aws_iam_role_policy_attachment.attachments_manual]
  role_name   = aws_iam_role.this.name
  policy_arns = concat(var.policy_arns, [for k, _ in var.policy_json_documents : module.manual_policies[k].policy_arn])
}

resource "aws_iam_role_policies_exclusive" "ensure_no_inline_policies" {
  role_name    = aws_iam_role.this.name
  policy_names = []
}