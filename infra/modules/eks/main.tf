# Fetch details of the existing EKS cluster
data "aws_eks_cluster" "this" {
  name = aws_eks_cluster.this.name
}

# Retrieve authentication token for the EKS cluster
data "aws_eks_cluster_auth" "this" {
  name = aws_eks_cluster.this.name
}

# Get TLS certificate from the cluster's OIDC issuer
data "tls_certificate" "eks" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# Create IAM OIDC provider for IRSA (IAM Roles for Service Accounts)
resource "aws_iam_openid_connect_provider" "this" {
  # OIDC issuer URL from the EKS cluster
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer

  # Allowed audience for AWS STS
  client_id_list = ["sts.amazonaws.com"]

  # SHA1 fingerprint of the OIDC TLS certificate
  thumbprint_list = [
    data.tls_certificate.eks.certificates[0].sha1_fingerprint
  ]
}

resource "aws_eks_cluster" "this" {
  name = "${var.env}-eks-cluster"

  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids = var.private_subnet_ids

    endpoint_private_access = true
    endpoint_public_access  = false
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }
  # Enable control plane logging for the EKS cluster
  enabled_cluster_log_types = [
    "api",               # Kubernetes API server logs (requests, responses)
    "audit",             # Audit logs for security and compliance
    "authenticator",     # Authentication logs (IAM, RBAC decisions)
    "controllerManager", # Controller manager activity (reconciliation loops)
    "scheduler"          # Pod scheduling decisions and events
  ]
}

resource "aws_kms_key" "eks" {
  description         = "EKS secrets encryption"
  enable_key_rotation = true # Enforced for security (production-ready)
}
