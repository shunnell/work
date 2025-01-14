provider "tls" {}

# Set up service account IAM per
# https://registry.terraform.io/providers/hashicorp/aws/5.56.0/docs/resources/eks_cluster#enabling-iam-roles-for-service-accounts
data "tls_certificate" "eks_cluster_thumbprint" {
  url = aws_eks_cluster.gitlab_runner_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_cluster_thumbprint.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.gitlab_runner_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_role" "gitlab_runner_sa_role" {
  name = "gitlab-runner-sa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.oidc_provider.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            # Remove the "https://" from the issuer URL in the key
            "${replace(aws_eks_cluster.gitlab_runner_cluster.identity[0].oidc[0].issuer, "https://", "")}:sub": "system:serviceaccount:gitlab-runner:gitlab-runner-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "gitlab_runner_s3_policy" {
  name = "gitlab_runner_s3_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::dos-gitlab-central-runner-cache/*"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "gitlab_runner_sa_s3_access" {
  role       = aws_iam_role.gitlab_runner_sa_role.name
  policy_arn = aws_iam_policy.gitlab_runner_s3_policy.arn
}
