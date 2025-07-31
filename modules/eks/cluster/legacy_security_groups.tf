# These are named and for-eached in ways that look redundant; this is done in order to trick terraform into not
# trying to replace any resources from the "old way" of managing node SGs. Doing that creates a dependency loop, where
# the SGs are destroyed before the old nodegroup, meaning that SG destroy times out, since the nodes are configured to
# reference these SGs are cluster-creation (third-party eks module invocation) time.
locals {
  legacy_sg_ids = var.legacy_nodegroup_sg_name == null ? {} : { (var.legacy_nodegroup_sg_name) = null }
}

module "node_security_groups" {
  source                 = "../../network/security_group"
  for_each               = local.legacy_sg_ids
  name_prefix            = "${var.cluster_name}-nodes-${each.key}-secondary"
  vpc_id                 = var.vpc_id
  tags                   = var.tags
  revoke_rules_on_delete = true # Forcibly delete it, since tenants might add rules to it externally.
}