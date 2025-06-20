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

Create and enter a directory in the `live` repository:
`<account>/<team>/<product>/<cluster-name>_eks`

Create a `terragrunt.hcl` file following the example of another cluster.

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
aws sso login --sso-session DoS
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

## Further Work

- Create the folder structer in the [kuberenetes](https://gitlab.cloud-city/cloud-city/platform/gitops/kubernetes) repository.  Read the [docs](https://gitlab.cloud-city/cloud-city/platform/gitops/kubernetes/-/blob/main/README.md) to understand the structure of that repository.
- [Bootstrap](../bootstrap/README.md) the cluster.

## Resizing Node Group

Changing a node group size requires a few manual steps, or replacing the node group.

### Increasing Size

1. Add `<node_group>.max_size` set to new size.
1. Apply changes.
1. Set desired size to new size in AWS Console.
1. Wait for node group to grow.
1. Set `<node_group>.size` to new size and remove `<node_group>.max_size`.
1. Apply changes again.

### Decreasing Size

1. Add `<node_group>.min_size` set to new size.
1. Apply changes.
1. Set desired size to new size in AWS Console.
1. Wait for node group to shrink.
1. Set `<node_group>.size` to new size and remove `<node_group>.min_size`.
1. Apply changes again.

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
| <a name="module_cluster_security_group"></a> [cluster\_security\_group](#module\_cluster\_security\_group) | ../../network/security_group | n/a |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | n/a |
| <a name="module_log_shipping"></a> [log\_shipping](#module\_log\_shipping) | ../../monitoring/cloudwatch_log_shipping_source | n/a |
| <a name="module_node_security_groups"></a> [node\_security\_groups](#module\_node\_security\_groups) | ../../network/security_group | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.cluster_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudwatch_log_group) | data source |
| [aws_ec2_instance_types.cloudcity_supported_ec2_types](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_instance_types) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_entries"></a> [access\_entries](#input\_access\_entries) | Map of access entries to add to the cluster | `map(any)` | `{}` | no |
| <a name="input_administrator_role_arns"></a> [administrator\_role\_arns](#input\_administrator\_role\_arns) | List of role ARNs that should have full administrator access to the cluster | `list(string)` | n/a | yes |
| <a name="input_cloudwatch_log_shipping_destination_arn"></a> [cloudwatch\_log\_shipping\_destination\_arn](#input\_cloudwatch\_log\_shipping\_destination\_arn) | ARN to ship CloudWatch logs generated in this cluster to (usually in a remote account for subsequent shipment to splunk). Temporarily allowed to be null, in which case logs will not be shipped, just stored locally. | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS Cluster | `string` | n/a | yes |
| <a name="input_cluster_security_group_rules"></a> [cluster\_security\_group\_rules](#input\_cluster\_security\_group\_rules) | Additional custom security group rules for the cluster control plane; should be a list of fields accepted by modules/network/security\_group\_traffic. Rules required for EKS operation and connection to VPC endpoints are automatically created and should not be specified. | <pre>map(object({<br/>    protocol = optional(string)<br/>    type     = string<br/>    ports    = list(number)<br/>    target   = string<br/>    // create_explicit_egress_to_target_security_group intentionally omitted; it is handled automatically internally for the cluster.<br/>  }))</pre> | n/a | yes |
| <a name="input_kuberenetes_version"></a> [kuberenetes\_version](#input\_kuberenetes\_version) | Kubernetes version to install; change this for existing clusters with care, as upgrades may be disruptive and require changes to cluster workloads | `string` | `"1.32"` | no |
| <a name="input_node_groups"></a> [node\_groups](#input\_node\_groups) | Map of Node Group objects, each of which may | <pre>map(object({<br/>    # TODO if we ever use node autoscaling, this can be broadened to allow either a number (static size) or a tuple/map of min/desired/max:<br/>    size     = number<br/>    min_size = optional(number, null) # for increasing size<br/>    max_size = optional(number, null) # for decreasing size<br/>    # Big enough to deploy infrastructure tooling and get started with tenant deployments:<br/>    # preferably, one of https://docs.aws.amazon.com/ec2/latest/instancetypes/ec2-nitro-instances.html<br/>    instance_type    = optional(string, "t3.xlarge")<br/>    volume_size      = optional(number, 20)<br/>    xvdb_volume_size = optional(number, null) # for EBS volume specified by the AMI<br/>    labels           = optional(map(string), {})<br/>    security_group_rules = map(object({<br/>      protocol = optional(string)<br/>      type     = string<br/>      ports    = list(number)<br/>      target   = string<br/>      # create_explicit_egress_to_target_security_group intentionally omitted and defaults to false, as the third party<br/>      # EKS module sets up an all-outbound rule.<br/>    }))<br/>    additional_iam_policy_arns = optional(list(string), [])<br/>  }))</pre> | n/a | yes |
| <a name="input_nodegroup_change_unavailable_percentage"></a> [nodegroup\_change\_unavailable\_percentage](#input\_nodegroup\_change\_unavailable\_percentage) | Percentage of nodes that can be offline during an upgrade. Higher means faster terraform applies, but more potential for temporary workload unavailability | `number` | `75` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the EKS cluster | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_entries"></a> [access\_entries](#output\_access\_entries) | Map of access entries created and their attributes |
| <a name="output_access_policy_associations"></a> [access\_policy\_associations](#output\_access\_policy\_associations) | Map, keyed by accessing principal, of cluster access policy associations created and their attributes |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | Arn of cloudwatch log group created - cluster logs |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint for your Kubernetes API server |
| <a name="output_cluster_iam_role_arn"></a> [cluster\_iam\_role\_arn](#output\_cluster\_iam\_role\_arn) | Cluster IAM role ARN |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | The name of the EKS cluster |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | ID of the cluster security group |
| <a name="output_cluster_service_cidr"></a> [cluster\_service\_cidr](#output\_cluster\_service\_cidr) | The CIDR block where Kubernetes pod and service IP addresses are assigned from |
| <a name="output_eks_managed_node_groups_autoscaling_group_names"></a> [eks\_managed\_node\_groups\_autoscaling\_group\_names](#output\_eks\_managed\_node\_groups\_autoscaling\_group\_names) | List of the autoscaling group names created by EKS managed node groups |
| <a name="output_node_groups"></a> [node\_groups](#output\_node\_groups) | n/a |
| <a name="output_oidc_provider"></a> [oidc\_provider](#output\_oidc\_provider) | The OpenID Connect identity provider (issuer URL without leading https:// or trailing slash) |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | The ARN of the OIDC Provider |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The cluster's VPC ID |
<!-- END_TF_DOCS -->
