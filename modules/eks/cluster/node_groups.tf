data "aws_ec2_instance_types" "cloudcity_supported_ec2_types" {
  filter {
    name   = "auto-recovery-supported"
    values = ["true"]
  }

  filter {
    name   = "bare-metal"
    values = ["false"]
  }

  filter {
    name   = "hypervisor"
    values = ["nitro"]
  }

  filter {
    name   = "processor-info.supported-architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "supported-boot-mode"
    values = ["uefi"]
  }
}

locals {
  instance_types = sort(data.aws_ec2_instance_types.cloudcity_supported_ec2_types.instance_types)
  # Other "fundamental to EKS" policies, like AmazonEKS_CNI_Policy or AmazonEKSWorkerNodePolicy, are always attached
  # inside the module below, and thus don't need to be listed here.
  baseline_node_iam_policies = [
    # All nodes can pull ECR images broadly. Generally, we do resource-based permissions on ECR images, which are all
    # stored in the infra account's ECR and have per-repo permissions which allow other accounts to pull them. Specific
    # EKS clusters aren't aware of/configured for being able to pull specific images; rather, they're given general
    # "pull all" permissions at the node level. Someday, EKS may support granular permissioning of what nodes/namespaces
    # are allowed to pull which ECR images, at which point the image-access permission model in Cloud City may change
    # to be more principal-oriented rather than resource-oriented. Reference for tracking some of AWS's work in this
    # area: https://github.com/aws/containers-roadmap/issues/2133
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly",
    "arn:aws:iam::aws:policy/AWSCodeArtifactReadOnlyAccess",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonInspector2ManagedCisPolicy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  ]
  node_group_configs = {
    for k, v in var.node_groups : k => {
      min_size               = coalesce(v.min_size, v.size)
      max_size               = coalesce(v.max_size, v.size)
      desired_size           = v.size
      instance_types         = [v.instance_type]
      vpc_security_group_ids = [module.node_security_groups[k].id]
      iam_role_additional_policies = { for p in toset(concat(
        v.additional_iam_policy_arns,
        local.baseline_node_iam_policies
      )) : p => p }
      labels = merge(v.labels, { "cloudcity-node-group" = k })
      block_device_mappings = {
        data = {
          device_name = "/dev/xvda"
          ebs = {
            delete_on_termination = true
            encrypted             = true
            volume_size           = v.volume_size
          }
        }
      }
      # disk_size = v.disk_size # not valid with custom launch template enabled
      # Constant/default values below this point:
      ami_type                       = "BOTTLEROCKET_x86_64"
      use_latest_ami_release_version = true
      capacity_type                  = "ON_DEMAND"
      # use_custom_launch_template   = true # for user data
      node_repair_config = {
        enabled = true
      }
      bootstrap_extra_args = <<-TOML
      # Ref https://aws.amazon.com/blogs/containers/validating-amazon-eks-optimized-bottlerocket-ami-against-the-cis-benchmark/
      # 3.4
      [settings.bootstrap-containers.cis-bootstrap]
      source = "381492150796.dkr.ecr.us-east-1.amazonaws.com/cloud-city/platform/bottlerocket-cis-bootstrap-image:latest"
      mode = "always"

      # 1.5.2
      [settings.kernel]
      lockdown = "integrity"

      [settings.kernel.sysctl]
      # 3.1.1
      "net.ipv4.conf.all.send_redirects" = "0"
      "net.ipv4.conf.default.send_redirects" = "0"

      # 3.2.2
      "net.ipv4.conf.all.accept_redirects" = "0"
      "net.ipv4.conf.default.accept_redirects" = "0"
      "net.ipv6.conf.all.accept_redirects" = "0"
      "net.ipv6.conf.default.accept_redirects" = "0"

      # 3.2.3
      "net.ipv4.conf.all.secure_redirects" = "0"
      "net.ipv4.conf.default.secure_redirects" = "0"

      # 3.2.4
      "net.ipv4.conf.all.log_martians" = "1"
      "net.ipv4.conf.default.log_martians" = "1"
      TOML
    }
  }
}
