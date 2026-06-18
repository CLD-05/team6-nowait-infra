# ========================================
# Network
# VPC / Subnet / NAT Gateway / Route Table
# ========================================
module "network" {
  source = "../../../modules/network"

  name_prefix = var.name_prefix

  vpc_cidr = var.vpc_cidr

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  availability_zones = local.azs

  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs

  # prod는 NAT Gateway를 AZ별로 구성
  nat_gateway_mode = var.nat_gateway_mode

  eks_cluster_name = local.eks_cluster_name

  # Karpenter EC2NodeClass subnet selector에서 사용
  enable_karpenter_discovery_tags = true

  common_tags = local.default_tags
}

# ========================================
# EKS
# Cluster / Node Group / Access Entry
# ========================================
module "eks" {
  source = "../../../modules/eks"

  name_prefix                   = var.name_prefix
  iam_role_permissions_boundary = var.iam_role_permissions_boundary

  vpc_id                 = module.network.vpc_id
  private_app_subnet_ids = module.network.private_app_subnet_ids

  cluster_version = var.eks_cluster_version

  # prod는 private endpoint 중심
  endpoint_public_access  = var.eks_endpoint_public_access
  endpoint_private_access = var.eks_endpoint_private_access
  public_access_cidrs     = var.eks_public_access_cidrs

  enabled_cluster_log_types = var.enabled_cluster_log_types
  log_retention_days        = var.log_retention_days

  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  node_instance_types = var.node_instance_types

  admin_principal_arns     = var.admin_principal_arns
  developer_principal_arns = var.developer_principal_arns
  viewer_principal_arns    = var.viewer_principal_arns

  common_tags = local.default_tags
}

# ========================================
# Security Groups
# RDS / Redis / Bastion
# ========================================
module "sg" {
  source = "../../../modules/sg"

  name_prefix = var.name_prefix
  vpc_id      = module.network.vpc_id
  vpc_cidr    = var.vpc_cidr

  eks_source_security_group_id = module.eks.node_security_group_id

  # prod는 Bastion SG 생성
  bastion_enabled = var.bastion_enabled

  common_tags = local.default_tags
}

# ========================================
# Bastion
# SSM Session Manager 전용
# ========================================
module "bastion" {
  source = "../../../modules/bastion"

  count = var.bastion_enabled ? 1 : 0

  name_prefix                   = var.name_prefix
  iam_role_permissions_boundary = var.iam_role_permissions_boundary

  vpc_id            = module.network.vpc_id
  subnet_id         = module.network.private_app_subnet_ids[0]
  security_group_id = module.sg.bastion_security_group_id

  instance_type   = var.bastion_instance_type
  eks_cluster_arn = module.eks.cluster_arn

  common_tags = local.default_tags
}

# ========================================
# RDS
# Multi-AZ DB Instance
# ========================================
module "database" {
  source = "../../../modules/database"

  name_prefix = var.name_prefix

  private_db_subnet_ids = module.network.private_db_subnet_ids
  security_group_id     = module.sg.rds_security_group_id

  engine_version = var.db_engine_version
  db_name        = var.db_name

  master_username = var.db_master_username

  # RDS password는 Terraform에 넣지 않고 RDS managed secret 사용
  manage_master_user_password = true

  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage

  multi_az            = var.db_multi_az
  publicly_accessible = false

  backup_retention_period = var.db_backup_retention

  deletion_protection       = var.db_deletion_protection
  skip_final_snapshot       = var.db_skip_final_snapshot
  final_snapshot_identifier = var.db_final_snapshot_identifier

  apply_immediately = var.db_apply_immediately

  common_tags = local.default_tags
}

# ========================================
# ElastiCache Redis
# Multi-AZ + Automatic Failover
# ========================================
module "elasticache" {
  source = "../../../modules/elasticache"

  name_prefix           = var.name_prefix
  vpc_id                = module.network.vpc_id
  private_db_subnet_ids = module.network.private_db_subnet_ids

  security_group_id = module.sg.redis_security_group_id

  node_type                  = var.redis_node_type
  replica_count              = var.redis_replica_count
  multi_az_enabled           = var.redis_multi_az_enabled
  automatic_failover_enabled = var.redis_automatic_failover
  snapshot_retention_limit   = var.redis_snapshot_retention_limit

  # prod는 네트워크 격리(보안그룹)만으로 방어선을 두지 않고 TLS + AUTH 토큰까지 켠다.
  # Redis에 refresh token / access token 블랙리스트가 저장되기 때문.
  transit_encryption_enabled = true
  auth_token_enabled         = true

  common_tags = local.default_tags
}

# ========================================
# S3
# Image Bucket & Frontend Bucket
# ========================================
module "s3" {
  source = "../../../modules/s3"

  name_prefix = var.name_prefix

  image_bucket_enabled    = var.image_bucket_enabled
  frontend_bucket_enabled = var.frontend_bucket_enabled

  cors_allowed_origins = var.cors_allowed_origins

  # [순환 참조 방지] 생성된 CloudFront의 ARN을 주입하여 버킷 정책이 허용하도록 함.
  cloudfront_distribution_arn = module.cloudfront.distribution_arn

  common_tags = local.default_tags
}

# ========================================
# CloudFront
# Frontend Production Distribution
# ========================================
module "cloudfront" {
  source = "../../../modules/cloudfront"

  name_prefix        = var.name_prefix
  common_tags        = local.default_tags
  cloudfront_enabled = var.cloudfront_enabled # prod 환경에서는 true로 주입.
  price_class        = var.price_class

  # S3 모듈에서 생성된 프론트엔드 버킷의 도메인 주소를 가져와 오리진으로 설정.
  frontend_bucket_domain_name = module.s3.frontend_bucket_domain_name
}

# ========================================
# Secrets Manager
# API / Redis secret container
# RDS는 RDS managed secret 사용
# ========================================
module "secrets" {
  source = "../../../modules/secrets"

  secret_prefix = "team6-nowait/${var.environment}"

  recovery_window_in_days = 30

  secrets = {
    api = {
      name_suffix = "api"
      description = "Application secrets for NoWait API in prod"
    }

    redis = {
      name_suffix = "redis"
      description = "Redis credentials for NoWait in prod"
    }
  }

  common_tags = local.default_tags
}

# ========================================
# Bastion EKS Access Entry
#
# SSM으로 Bastion에 접속한 뒤 Bastion Instance Role로
# kubectl / Helm 작업을 수행할 수 있도록 EKS Access Entry를 등록합니다.
# ========================================
resource "aws_eks_access_entry" "bastion" {
  count = var.bastion_enabled ? 1 : 0

  cluster_name  = module.eks.cluster_name
  principal_arn = module.bastion[0].role_arn
  type          = "STANDARD"

  depends_on = [
    module.eks,
    module.bastion
  ]
}

resource "aws_eks_access_policy_association" "bastion_cluster_admin" {
  count = var.bastion_enabled ? 1 : 0

  cluster_name  = module.eks.cluster_name
  principal_arn = module.bastion[0].role_arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.bastion
  ]
}
