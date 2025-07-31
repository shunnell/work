# See the 'Programmatic modification of the AWS-created EKS "Cluster security group"' section of eks/cluster/README.tf
# for details as to what's going on here:
data "aws_vpc_security_group_rule" "cluster_egress_rules" {
  for_each               = var.aws_internal_cluster_egress_rule_ids
  security_group_rule_id = each.key
}

# NOTE WELL: Do NOT propagate this pattern (checked-in programmatic "import" blocks) basically anywhere else in the
# codebase. This should basically never be done, and this is one of a few very, *very* rare cases where auto-import is
# appropriate in Terraform. Import blocks, the rest of the time, should live only in throwaway code during manual
# state repair processes, and should never land in "main".
import {
  for_each = var.aws_internal_cluster_egress_rule_ids
  id       = each.key
  to       = aws_vpc_security_group_egress_rule.aws_managed_cluster_sg_egress_restrict[each.key]
}

resource "aws_vpc_security_group_egress_rule" "aws_managed_cluster_sg_egress_restrict" {
  for_each          = var.aws_internal_cluster_egress_rule_ids
  ip_protocol       = "-1"
  security_group_id = data.aws_vpc_security_group_rule.cluster_egress_rules[each.key].security_group_id
  # This is the only line that should cause plan diff; it updates the egress rule to only allow egress to a non-routable
  # IP (localhost). This effectively "neuters" the outbound rule.
  # The localhost-retarget approach was chosen over other changes we could make because changing the CIDR block does not
  # cause terraform to replace the resource, just update it--many other changes do require replacement, which we want
  # to avoid in case AWS tracks the security group rule by ID internally.
  cidr_ipv4 = "127.0.0.1/32"
}