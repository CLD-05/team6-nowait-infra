# ----------------------------------------
# EKS Cluster IAM Role
# ----------------------------------------
resource "aws_iam_role" "eks_cluster" {
  name                 = "${var.name_prefix}-eks-cluster-role"
  permissions_boundary = var.iam_role_permissions_boundary

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# ----------------------------------------
# EKS Cluster
# ----------------------------------------
resource "aws_eks_cluster" "main" {
  name     = "${var.name_prefix}-eks"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.private_app_subnet_ids
    endpoint_public_access  = var.eks_endpoint_public_access
    endpoint_private_access = var.eks_endpoint_private_access
    public_access_cidrs     = var.eks_public_access_cidrs
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

# ----------------------------------------
# EKS Node Group IAM Role
# ----------------------------------------
resource "aws_iam_role" "eks_node" {
  name                 = "${var.name_prefix}-eks-node-role"
  permissions_boundary = var.iam_role_permissions_boundary

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# EKS Node가 EKS Control Plane과 통신하는 권한
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# Pod에 VPC IP를 할당하는 권한
resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# ECR에서 Docker 이미지를 pull 하는 권한
resource "aws_iam_role_policy_attachment" "eks_ecr_readonly" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# ----------------------------------------
# EKS Managed Node Group
# ----------------------------------------
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.name_prefix}-node-group"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = var.private_app_subnet_ids

  instance_types = var.node_instance_types

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_readonly
  ]
}

# ----------------------------------------
# EKS Access Entry (팀원 IAM User)
# ----------------------------------------
locals {
  admin_entries = {
    for arn in var.admin_principal_arns :
    arn => { policy = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy" }
  }

  developer_entries = {
    for arn in var.developer_principal_arns :
    arn => { policy = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy" }
  }

  viewer_entries = {
    for arn in var.viewer_principal_arns :
    arn => { policy = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy" }
  }

  all_entries = merge(local.admin_entries, local.developer_entries, local.viewer_entries)
}

resource "aws_eks_access_entry" "main" {
  for_each = local.all_entries

  # for_each 사용 시 terraform에서 자동으로 each 변수 생성 (count -> count.index와 마찬가지)
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = each.key
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "main" {
  for_each = local.all_entries

  cluster_name  = aws_eks_cluster.main.name
  principal_arn = each.key
  policy_arn    = each.value.policy

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.main]
}
