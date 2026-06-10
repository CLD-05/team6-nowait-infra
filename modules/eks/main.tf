# ----------------------------------------
# EKS Cluster IAM Role
# ----------------------------------------
resource "aws_iam_role" "cluster" {
  name = "${var.name_prefix}-eks-cluster-role"

  # 학원 정책상 IAM Role에는 permissions boundary가 필수입니다.
  permissions_boundary = var.iam_role_permissions_boundary

  # 이 Role은 EKS 서비스가 Assume할 수 있어야 합니다.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.name_prefix}-eks-cluster-role"
  }
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# --------------------------------------------------------
# EKS Control Plane 로그를 저장할 CloudWatch Log Group
# --------------------------------------------------------
resource "aws_cloudwatch_log_group" "cluster" {
  name              = "/aws/eks/${local.cluster_name}/cluster"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "/aws/eks/${local.cluster_name}/cluster"
  }
}


# ----------------------------------------
# EKS Cluster
# ----------------------------------------
resource "aws_eks_cluster" "this" {
  name     = local.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.cluster_version

  # EKS Access Entry 방식을 사용하기 위한 설정입니다.
  #
  # API_AND_CONFIG_MAP:
  # - 새 방식인 Access Entry 사용 가능
  # - 기존 aws-auth ConfigMap 방식도 병행 가능
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  # Control Plane 로그 활성화
  enabled_cluster_log_types = var.enabled_cluster_log_types

  vpc_config {
    # EKS Cluster가 사용할 subnet입니다.
    # 여기에는 private app subnet을 넣습니다.
    subnet_ids = var.private_app_subnet_ids

    # dev는 public endpoint true 가능
    # prod는 public endpoint false 권장
    endpoint_public_access  = var.endpoint_public_access
    endpoint_private_access = var.endpoint_private_access

    # public endpoint를 열 경우 접근 가능한 IP 목록입니다.
    public_access_cidrs = var.public_access_cidrs
  }

  tags = {
    Name = local.cluster_name
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
    aws_cloudwatch_log_group.cluster
  ]
}

# ----------------------------------------
# EKS Node Group IAM Role
# ----------------------------------------
resource "aws_iam_role" "node" {
  name = "${var.name_prefix}-eks-node-role"

  # 학원 정책상 IAM Role에는 permissions boundary가 필수입니다.
  permissions_boundary = var.iam_role_permissions_boundary

  # 이 Role은 EC2가 Assume할 수 있어야 합니다.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.name_prefix}-eks-node-role"
  }
}

# EKS Node가 EKS Control Plane과 통신하는 권한
resource "aws_iam_role_policy_attachment" "node_worker" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# Pod에 VPC IP를 할당하는 권한
resource "aws_iam_role_policy_attachment" "node_cni" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# ECR에서 Docker 이미지를 pull 하는 권한
resource "aws_iam_role_policy_attachment" "node_ecr" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# ----------------------------------------
# EKS Managed Node Group
# ----------------------------------------
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.name_prefix}-main-ng"
  node_role_arn   = aws_iam_role.node.arn

  # Worker Node는 private app subnet에 배치합니다.
  subnet_ids = var.private_app_subnet_ids

  instance_types = var.node_instance_types
  disk_size      = var.node_disk_size

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  # Node Group 업데이트 시 한 번에 교체 가능한 노드 수입니다.
  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "app"
  }

  tags = {
    Name = "${var.name_prefix}-main-ng"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker,
    aws_iam_role_policy_attachment.node_cni,
    aws_iam_role_policy_attachment.node_ecr
  ]
}

# ----------------------------------------
# EKS Access Entry (팀원 IAM User)
# ----------------------------------------
resource "aws_eks_access_entry" "this" {
  for_each = local.access_entries

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = each.value.principal_arn
  type          = "STANDARD"

  depends_on = [aws_eks_cluster.this]
}

# Access Entry에 실제 권한 정책을 연결합니다.
#
# admin/developer/viewer에 따라 다른 EKS access policy가 연결됩니다.
resource "aws_eks_access_policy_association" "this" {
  for_each = local.access_entries

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = each.value.principal_arn
  policy_arn    = each.value.policy_arn

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.this]
}
