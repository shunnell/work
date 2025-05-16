data "aws_eks_cluster" "this" {
  # This variable is expected by `modules/eks/*`
  name = var.cluster_name
}

# Unfortunately must be a data variable since the AWS provider does not yet support ephemeral resources for this type:
data "aws_ecr_authorization_token" "ecr_token" {
  # Always pull ECR credentials for the infra account, regardless of what account is being targeted by Helm. This
  # allows IaC code written with chart addresses in "infra" to apply those charts to other accounts.
  provider = aws.infra_terragrunter_provider
}

ephemeral "aws_eks_cluster_auth" "this" {
  name = data.aws_eks_cluster.this.name
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = ephemeral.aws_eks_cluster_auth.this.token
  }
  registry {
    url      = "oci://381492150796.dkr.ecr.us-east-1.amazonaws.com"
    password = sensitive(data.aws_ecr_authorization_token.ecr_token.password)
    username = sensitive(data.aws_ecr_authorization_token.ecr_token.user_name)
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = ephemeral.aws_eks_cluster_auth.this.token
}
