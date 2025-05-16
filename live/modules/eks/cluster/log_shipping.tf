locals {
  log_groups = [
    "/aws/eks/${var.cluster_name}/cluster",
    "/aws/containerinsights/${var.cluster_name}/application",
    "/aws/containerinsights/${var.cluster_name}/dataplane",
    "/aws/containerinsights/${var.cluster_name}/performance",
  ]
}

# We use a data variable, even though we could hand-lookup the ARN, as a means of validating that the log groups exist
# as expected:
data "aws_cloudwatch_log_group" "cluster_logs" {
  # Once the cloudwatch addon is provisioned, it takes a little while for it to finish provisioning the CloudWatch logs
  # entities it writes output to, so wait on those here before setting them up for shipment:
  depends_on = [
    module.eks.cluster_addons,
    module.eks.eks_managed_node_groups,
  ]
  count = length(local.log_groups)
  name  = local.log_groups[count.index]
}

module "log_shipping" {
  count           = var.cloudwatch_log_shipping_destination_arn == null ? 0 : 1
  source          = "../../monitoring/cloudwatch_log_shipping_source"
  destination_arn = var.cloudwatch_log_shipping_destination_arn
  log_group_arns  = data.aws_cloudwatch_log_group.cluster_logs[*].arn
}
