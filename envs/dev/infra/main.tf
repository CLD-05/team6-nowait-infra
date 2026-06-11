# ========================================
# Network
# VPC / Subnet / NAT Gateway / Route Table
# ========================================
module "network" {
  source = "../../../modules/network"

  name_prefix = var.name_prefix

  # dev VPC CIDR
  vpc_cidr = var.vpc_cidr

  # VPC DNS 설정
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  # root locals.tf에서 조회한 AZ 목록
  availability_zones = local.azs

  # dev subnet CIDR
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs

  # dev는 NAT Gateway 1개
  nat_gateway_mode = var.nat_gateway_mode

  # subnet에 붙일 Kubernetes cluster tag
  eks_cluster_name = local.eks_cluster_name

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

  common_tags = local.default_tags

}


# ========================================
# Security Groups
# ALB / EKS Node / RDS / Redis / Bastion
#
# network 모듈 이후에 생성합니다.
# 각 모듈(elasticache, database 등)은 여기서 생성된 SG ID를 받아서 사용합니다.
# ========================================
module "sg" {
  source = "../../../modules/sg"

  name_prefix = var.name_prefix
  vpc_id      = module.network.vpc_id
  vpc_cidr    = var.vpc_cidr

  eks_source_security_group_id = module.eks.node_security_group_id

  bastion_enabled = false

  common_tags = local.default_tags
}


# ========================================
# RDS
# ========================================
module "database" {
  source = "../../../modules/database"

  name_prefix = var.name_prefix

  private_db_subnet_ids = module.network.private_db_subnet_ids
  security_group_id     = module.sg.rds_security_group_id

  engine_version = var.db_engine_version
  db_name        = var.db_name

  master_username = var.db_master_username
  master_password = var.db_master_password

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
# ElastiCache (Redis)
# Subnet Group / Replication Group
#
# SG는 modules/sg에서 생성한 redis_security_group_id를 사용합니다.
# ========================================
module "elasticache" {
  source = "../../../modules/elasticache"

  name_prefix           = var.name_prefix
  vpc_id                = module.network.vpc_id
  private_db_subnet_ids = module.network.private_db_subnet_ids

  # modules/sg에서 생성한 Redis SG ID를 넘깁니다.
  security_group_id = module.sg.redis_security_group_id

  # dev 환경 설정
  node_type                  = var.redis_node_type
  replica_count              = var.redis_replica_count
  multi_az_enabled           = var.redis_multi_az_enabled
  automatic_failover_enabled = var.redis_automatic_failover
  snapshot_retention_limit   = var.redis_snapshot_retention_limit

  common_tags = local.default_tags
}

# ========================================
# S3
# Image Bucket / Frontend Bucket
#
# dev: image_bucket_enabled = true
#      frontend_bucket_enabled = false
# ========================================
module "s3" {
  source = "../../../modules/s3"

  name_prefix = var.name_prefix

  image_bucket_enabled    = var.image_bucket_enabled
  frontend_bucket_enabled = var.frontend_bucket_enabled

  cors_allowed_origins = var.cors_allowed_origins

  # frontend_bucket_enabled = false인 dev에서는 null
  cloudfront_distribution_arn = var.cloudfront_enabled ? module.cloudfront.distribution_arn : null

  common_tags = local.default_tags
}

# ========================================
# CloudFront
# S3 Frontend + ALB 오리진
#
# dev 초기: cloudfront_enabled = false
# prod: cloudfront_enabled = true
# ========================================
module "cloudfront" {
  source = "../../../modules/cloudfront"

  name_prefix = var.name_prefix

  cloudfront_enabled = var.cloudfront_enabled

  # cloudfront_enabled = false인 dev에서는 null
  frontend_bucket_domain_name = var.frontend_bucket_enabled ? module.s3.frontend_bucket_domain_name : null
  alb_dns_name                = var.cloudfront_enabled ? var.alb_dns_name : null

  common_tags = local.default_tags
}
