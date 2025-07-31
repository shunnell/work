# The "proper", non-legacy per-nodegroup SG config. See "Node Security Groups" in the README for more info.
# NB that the legacy SGs are managed in a similarly-named module, "node_security_groups", with an "s". Ugly/confusing,
# but temporary.
module "node_security_group" {
  source                 = "../../network/security_group"
  for_each               = var.node_groups
  name                   = "platform/eks/${var.cluster_name}/nodes/${each.key}"
  vpc_id                 = var.vpc_id
  tags                   = var.tags
  revoke_rules_on_delete = true # Forcibly delete it, since tenants might add rules to it externally.
}

# See the 'Programmatic modification of the AWS-created EKS "Cluster security group"' section of eks/cluster/README.md
# for details as to what's going on here:
data "aws_vpc_security_group_rules" "aws_managed_cluster_ruleset" {
  filter {
    name   = "group-id"
    values = [module.eks.cluster_primary_security_group_id]
  }
}

data "aws_vpc_security_group_rule" "aws_managed_cluster_rules" {
  for_each               = toset(data.aws_vpc_security_group_rules.aws_managed_cluster_ruleset.ids)
  security_group_rule_id = each.key
}

locals {
  aws_generated_egress_rules = [
    for r in data.aws_vpc_security_group_rule.aws_managed_cluster_rules :
    r.id if r.is_egress
  ]
}
