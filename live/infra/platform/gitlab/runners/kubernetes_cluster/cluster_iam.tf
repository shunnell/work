
resource "aws_iam_role" "eks_role" {
  name = "dos_gitlab_central_runner_eks_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Allow EKS to assume roles for its internal cluster operations, per
      # https://docs.aws.amazon.com/eks/latest/userguide/cluster-iam-role.html
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
      # NB: When importing these resources from gitlab-iac, the below stanza for ec2 was found to be drift. I don't
      # know why it was added, or how (probably manually), but it's written here to produce a clean plan, not necessarily
      # because we know why it's needed. The EKS IAM docs do not discuss any need for such a policy.
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEKSVPCResourceControllerPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_role.name
}
