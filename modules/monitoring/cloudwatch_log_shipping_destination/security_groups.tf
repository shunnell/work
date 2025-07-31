# Rather than using terraform-aws-modules/eks/aws' fields for e.g. node_security_group_additional_rules, we do it
# externally in our own security groups. This is done because some network access is needed for node groups to launch
# in the first place, and that access must be set up in other, external Security Groups by ID. Since there's no way
# to inject access rules "between" the EKS module's creation of its internal SGs and the creation of node groups, we
# create the needed access rules before the EKS module is instantiated, and then attach our new security groups to node
# groups and the cluster control plane as "secondary" security groups which add needed access. These groups will be
# used inside the EKS deployment in addition to the groups/rules needed for EKS internal operations (e.g. nodes will
# be connected to the cluster control plane via other SGs created inside the module below).

data "aws_subnet" "vpc_subnet" {
  id = var.vpc_subnet_ids[0]
}

module "lambda_security_group" {
  source      = "../../network/security_group"
  name_prefix = "FSP-${var.destination_name}"
  vpc_id      = data.aws_subnet.vpc_subnet.vpc_id
  tags        = var.tags
}