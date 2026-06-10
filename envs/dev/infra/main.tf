# ========================================
# Network
# VPC / Subnet / NAT Gateway / Route Table
# ========================================
module "network" {
  source = "../../../modules/network"

  name_prefix = var.name_prefix

  # dev VPC CIDR
  vpc_cidr = var.vpc_cidr

  # root locals.tf에서 조회한 AZ 목록을 넘깁니다.
  availability_zones = local.azs

  # dev subnet CIDR
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs

  # dev는 NAT Gateway 1개
  nat_gateway_mode = var.nat_gateway_mode

  # subnet에 붙일 Kubernetes cluster tag
  eks_cluster_name = "${var.name_prefix}-eks"
}

# ========================================
# EKS
# Cluster / Node Group / Access Entry
# ========================================
module "eks" {
  source = "../../../modules/eks"

  name_prefix                   = var.name_prefix
  iam_role_permissions_boundary = var.iam_role_permissions_boundary

  # Network 모듈에서 만든 VPC/Subnet을 사용합니다.
  vpc_id                 = module.network.vpc_id
  private_app_subnet_ids = module.network.private_app_subnet_ids

  # EKS 버전은 1.34로 고정합니다.
  cluster_version = var.eks_cluster_version

  # dev/prod endpoint 설정은 tfvars에서 제어합니다.
  endpoint_public_access  = var.eks_endpoint_public_access
  endpoint_private_access = var.eks_endpoint_private_access
  public_access_cidrs     = var.eks_public_access_cidrs

  # Control Plane 로그 설정
  enabled_cluster_log_types = var.enabled_cluster_log_types
  log_retention_days        = var.log_retention_days

  # Node Group 설정
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  node_instance_types = var.node_instance_types

  # 팀원 EKS 접근 권한
  admin_principal_arns     = var.admin_principal_arns
  developer_principal_arns = var.developer_principal_arns
  viewer_principal_arns    = var.viewer_principal_arns
}

# ========================================
# ECR
# Repository / Lifecycle Policy
# ========================================
module "ecr" {
  source = "../../../modules/ecr"

  name_prefix = var.name_prefix

  # 생성할 Repository 목록
  # tfvars에서 서비스별 이름을 지정합니다.
  repositories = var.ecr_repositories

  # 이미지 태그 설정
  # dev: MUTABLE (latest 태그 재사용 가능)
  image_tag_mutability = var.ecr_image_tag_mutability

  # push 시 자동 취약점 스캔
  scan_on_push = var.ecr_scan_on_push

  # Lifecycle Policy
  # 오래된 이미지 자동 정리
  lifecycle_policy_enabled = var.ecr_lifecycle_policy_enabled
  max_image_count          = var.ecr_max_image_count
  untagged_image_days      = var.ecr_untagged_image_days
}
