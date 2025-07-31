# EKS Deployment

Create an EKS cluster.

## Prerequisites

- Installed and configured AWS CLI
- Installed Terragrunt and Terraform
- Access to the `live` and `modules` repositories

## Ensure that Your Workstation is Setup for Cloud City IaC

Follow the [`Cloud City IaC Workstation Setup`](https://gitlab.cloud-city/cloud-city/platform/iac/live/-/blob/main/doc/setup.md) to configure your workstation with necessary tools and access.

## Setup EKS deployment

Ensure that there is:
 - A `VPC` available for the cluster

## Initialize and plan using Terragrunt

Open a terminal in the directory to validate the configuration:
```shell
terragrunt hclfmt
terragrunt hclvalidate
terragrunt init
terragrunt plan -out=tfplan
```

## Login to AWS

You may need to login to AWS services first.
```shell
aws sso login --sso-session dos
```

## Creating and Inspecting

Open a terminal in the directory to validate the configuration:
```shell
terragrunt apply "tfplan"
aws eks update-kubeconfig --region us-east-1 --profile <account> --name <cluster-name> --alias <account>-<cluster-name>
kubectl get namespaces
```

### Validating the Bottlerocket AMI against the CIS Benchmark
https://aws.amazon.com/blogs/containers/validating-amazon-eks-optimized-bottlerocket-ami-against-the-cis-benchmark/
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: eks-cis-benchmark
spec:
  ttlSecondsAfterFinished: 6000
  template:
    metadata:
      labels:
        app: eks-cis-benchmark  
    spec:
      hostNetwork: true  
      containers:
        - name: eks-cis-benchmark
          image: 381492150796.dkr.ecr.us-east-1.amazonaws.com/cloud-city/platform/bottlerocket-cis-validation-image
          imagePullPolicy: Always
          securityContext:
            capabilities:
              add: ["SYS_ADMIN", "NET_ADMIN", "CAP_SYS_ADMIN"]
          volumeMounts:
          - mountPath: /.bottlerocket/rootfs
            name: btl-root
      volumes:
      - name: btl-root
        hostPath:
          path: /
      restartPolicy: Never
```

### Troubleshooting

**Error: Access Denied**
Ensure that you have logged into AWS using sso

# Node Security Groups

Each node in each node-group in a cluster will be in three SGs:
1. `platform/eks/$cluster/nodes/all`, an SG that all nodes in all groups are in. Tenants should generally not use this, 
    but platform stuff (e.g. the LBC) might.
2. `platform/eks/$cluster/nodes/$nodegroup`, An SG that's empty, for use by tenants/custom code to add traffic to/from 
    specific node groups without interfering with/breaking the internal required SG routing inside the cluster.
3. A legacy SG that tenants have been adding rules to, preserved only until they migrate to one of the below (any time).

The reason for the multiplicity of the first and second items is as follows: the third-party terraform module we use to 
provision EKS clusters only makes one security group for all nodes in all nodegroups, which it configures properly to 
let nodes connect to the EKS control plane. However, that security group is not a good option when it comes to providing 
security groups to cluster users for their own customization purposes, for two reasons:

1. It's not per-nodegroup, it's for all nodegroups, so it can't represent per-node-group restrictions.
2. It's managed inside a third party module and thus alterations to it from the outside may produce unexpected issues.

To get around that, we add a per-nodegroup additional SG to all nodes which can contain custom rules--and which may
contain rules set outside of our terraform, since tenants may customize this SG after looking it up externally.

# AWS EKS Add-Ons

EKS addons are basically helm charts, installed and pre-configured by AWS with known-working, best-practices-encoding
values and behavior. In general, if software is available as an addon, helm chart, and raw Kubernetes manifest, always
prefer the addon version if it works.

We manage addons in `addons.tf`. Addons can be installed in two places: on the cluster module itself, or individually 
vis in a terraform `aws_eks_addon` resource. In general, prefer the cluster-module version, and use the raw TF version 
if the cluster version has issues (e.g. with dependency order or addons not working).

References:
- What configs/IAM requirements are needed by each addon: https://docs.aws.amazon.com/eks/latest/userguide/community-addons.html
- How to install them directly with Terraform: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon
- Detailed configuration and manifest documentation for each AWS-written addon: https://github.com/awslabs/cdk-eks-blueprints/tree/main/docs/addons

Example:

```terraform
resource "aws_eks_addon" "example" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "coredns"
  addon_version               = "v1.10.1-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
  # Addons might need to communicate between nodes, so the nodegroup and all communication rules must first be set up:
  depends_on = [module.eks, module.node_security_groups, module.cluster_security_group]

  # NOTE: Configuration values are here as an example. Most addons should NOT have configuration values, so remove
  # this if it's not strictly necessary (e.g. to configure correct addon operation).
  configuration_values = jsonencode({

    resources = {
      requests = {
        cpu    = "100m"
        memory = "150Mi"
      }
    }
  })
}
```

# Required Next Steps

Setup a [bootstrap](../bootstrap) terragrunt for the cluster.  The reason for the second part is because there are some additional things to configure and add; such as monitoring, storageclass and security group rules.

## Programmatic modification of the AWS-created EKS "Cluster security group"

Okay, strap in. This is going to get weird.

Inside the AWS EKS module we call, *two* security groups are created for the cluster itself. One is managed by the 
`terraform-aws-modules/eks/aws` module, and has rules in it for node/cluster communication and such--that's the one 
controlled by the 'cluster_security_group_additional_rules' parameter.

But they were, all of them, deceived, for another security group was made: AWS itself, when an EKS cluster is created,
makes and configures a security group that it attaches to the cluster. This is the group listed at the top of the
"Cluster security group" field in the EKS "Networking" UI. This group has rules in it controlled by AWS, but AWS
also allows users to remove those roles...but it'll put them back every time the cluster is updated.

That sounds crazy, so before continuing, read this: https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html

That's real weird. Nothing else in AWS works quite like this--other things that are "AWS managed" entities usually
don't let you modify them at all, much less recommend it!

That, however, poses a problem for us. The allow-all rules (re)created by AWS are often flagged as security issues,
so we need to disable them somehow, automatically. Getting rid of those rules is a three step process:
1. We set up rules that allow necessary cluster<->node traffic using the code in main.tf, adjacent to this.
2. We grab the rule IDs of all the rules (re)created by AWS on the AWS-internal cluster security group here, and
   output them.
3. Then, in bootstrap, we Terraform-import those rules *unconditionally*, and update them to render them nonfunctional
   by removing the broad 0.0.0.0/0 CIDR from them and replacing it with a non-routable CIDR. This has to be done in
   bootstrap (or another module), because imports can't depend on resources or data variables, so we need to "launder"
   the security group rule IDs through a cross-entry-point-module variable in order to allow the other module to use
   an "import" block.

All of that gets us to the ability to *deactivate* a security group rule that is dynamically (re)created *outside* of
terraform. Since we can't delete rules (there's no "ensure resource is absent" statement in Terraform, though I wish it
was more like Puppet in this regard), and since we don't want the bootstrap module to manage the whole AWS-managed
security group and all its rules (since deletion would occur on bootstrap destroy), that's the best we can do in terms
of automating resolution of security issues posed by the AWS-managed group's rules.

In a better timeline, AWS would offer CreateEKSCluster provisioning flags, which Terraform could use, that would allow
finer-grained control of that magic internal security group. Alas, we do not live in that timeline.

# For pushing/pulling charts and images

Additional reference.
```shell
aws sso login --sso-session dos
aws ecr get-login-password --region us-east-1 | helm registry login --username AWS --password-stdin 381492150796.dkr.ecr.us-east-1.amazonaws.com
aws ecr get-login-password --region us-east-1 | podman login --username AWS --password-stdin 381492150796.dkr.ecr.us-east-1.amazonaws.com
```

# Terraform Docs

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 20.37.1 |
| <a name="module_log_shipping"></a> [log\_shipping](#module\_log\_shipping) | ../../monitoring/cloudwatch_log_shipping_source | n/a |
| <a name="module_node_security_group"></a> [node\_security\_group](#module\_node\_security\_group) | ../../network/security_group | n/a |
| <a name="module_node_security_groups"></a> [node\_security\_groups](#module\_node\_security\_groups) | ../../network/security_group | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ec2_instance_types.cloudcity_supported_ec2_types](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_instance_types) | data source |
| [aws_vpc_security_group_rule.aws_managed_cluster_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_security_group_rule) | data source |
| [aws_vpc_security_group_rules.aws_managed_cluster_ruleset](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_security_group_rules) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_entries"></a> [access\_entries](#input\_access\_entries) | Map of access entries to add to the cluster | `map(any)` | `{}` | no |
| <a name="input_administrator_role_arns"></a> [administrator\_role\_arns](#input\_administrator\_role\_arns) | List of role ARNs that should have full administrator access to the cluster | `list(string)` | n/a | yes |
| <a name="input_cloudwatch_log_shipping_destination_arn"></a> [cloudwatch\_log\_shipping\_destination\_arn](#input\_cloudwatch\_log\_shipping\_destination\_arn) | ARN to ship CloudWatch logs generated in this cluster to (usually in a remote account for subsequent shipment to splunk). Temporarily allowed to be null, in which case logs will not be shipped, just stored locally. | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS Cluster | `string` | n/a | yes |
| <a name="input_kubernetes_control_plane_allowed_cidrs"></a> [kubernetes\_control\_plane\_allowed\_cidrs](#input\_kubernetes\_control\_plane\_allowed\_cidrs) | CIDR ranges which can access port 443 on the kubernetes control plane (this is just for kubectl/tf/helm access, not the nodes; node access should be done by referencing the 'node\_groups.[*].security\_group\_id') | `set(string)` | `[]` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version to install; change this for existing clusters with care, as upgrades may be disruptive and require changes to cluster workloads | `string` | `"1.32"` | no |
| <a name="input_legacy_nodegroup_sg_name"></a> [legacy\_nodegroup\_sg\_name](#input\_legacy\_nodegroup\_sg\_name) | Whether to keep legacy-naming-scheme SGs around for nodegroups (tenants may have added rules referencing those SGs); should eventually go to 'false' everywhere | `string` | `null` | no |
| <a name="input_node_groups"></a> [node\_groups](#input\_node\_groups) | Map of Node Group objects, each of which may | <pre>map(object({<br/>    # TODO if we ever use node autoscaling, this can be broadened to allow either a number (static size) or a tuple/map of min/desired/max:<br/>    size = number<br/>    # m5.large is big enough to deploy infrastructure tooling and get started with tenant deployments, tested on<br/>    # multiple tenants small/ordinary/baseline deployments:<br/>    instance_type              = optional(string, "m5.large")<br/>    volume_size                = optional(number, 20)<br/>    xvdb_volume_size           = optional(number, null) # for EBS volume specified by the AMI<br/>    labels                     = optional(map(string), {})<br/>    additional_iam_policy_arns = optional(list(string), [])<br/>  }))</pre> | n/a | yes |
| <a name="input_nodegroup_change_unavailable_percentage"></a> [nodegroup\_change\_unavailable\_percentage](#input\_nodegroup\_change\_unavailable\_percentage) | Percentage of nodes that can be offline during an upgrade. Higher means faster terraform applies, but more potential for temporary workload unavailability | `number` | `75` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the EKS cluster | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_entries"></a> [access\_entries](#output\_access\_entries) | Map of access entries created and their attributes |
| <a name="output_access_policy_associations"></a> [access\_policy\_associations](#output\_access\_policy\_associations) | Map, keyed by accessing principal, of cluster access policy associations created and their attributes |
| <a name="output_aws_internal_cluster_egress_rule_ids"></a> [aws\_internal\_cluster\_egress\_rule\_ids](#output\_aws\_internal\_cluster\_egress\_rule\_ids) | SG rule IDs of AWS-managed egress rules from the AWS-managed cluster SG; see README.md for more details. |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | Arn of cloudwatch log group created - cluster logs |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint for your Kubernetes API server |
| <a name="output_cluster_iam_role_arn"></a> [cluster\_iam\_role\_arn](#output\_cluster\_iam\_role\_arn) | Cluster IAM role ARN |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | The name of the EKS cluster |
| <a name="output_cluster_service_cidr"></a> [cluster\_service\_cidr](#output\_cluster\_service\_cidr) | The CIDR block where Kubernetes pod and service IP addresses are assigned from |
| <a name="output_eks_managed_node_groups_autoscaling_group_names"></a> [eks\_managed\_node\_groups\_autoscaling\_group\_names](#output\_eks\_managed\_node\_groups\_autoscaling\_group\_names) | List of the autoscaling group names created by EKS managed node groups |
| <a name="output_node_groups"></a> [node\_groups](#output\_node\_groups) | n/a |
| <a name="output_oidc_provider"></a> [oidc\_provider](#output\_oidc\_provider) | The OpenID Connect identity provider (issuer URL without leading https:// or trailing slash) |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | The ARN of the OIDC Provider |
| <a name="output_shared_node_security_group_id"></a> [shared\_node\_security\_group\_id](#output\_shared\_node\_security\_group\_id) | ID of the security group shared amongst all nodes, named 'platform/eks/<clustername>/nodes/all' |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The cluster's VPC ID |
<!-- END_TF_DOCS -->
