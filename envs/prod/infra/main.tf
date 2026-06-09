# 이 파일은 envs/dev/infra 또는 envs/prod/infra의 진입점입니다.
# 현재는 PR 1 공통 구조 단계라 실제 리소스 module 호출은 주석 처리해둡니다.
# 다음 PR부터 network → eks → data resources 순서로 활성화하면 됩니다.

# 1단계: VPC / Subnet / NAT / Route Table
# module "network" {
#   source = "../../../modules/network"
#
#   name_prefix              = var.name_prefix
#   vpc_cidr                 = var.vpc_cidr
#   availability_zones       = local.azs
#   public_subnet_cidrs      = var.public_subnet_cidrs
#   private_app_subnet_cidrs = var.private_app_subnet_cidrs
#   private_db_subnet_cidrs  = var.private_db_subnet_cidrs
#   nat_gateway_mode         = var.nat_gateway_mode
# }

# 2단계: EKS Cluster / Node Group / Access Entry
# IAM Role을 생성하므로 permissions boundary를 반드시 넘겨야 합니다.
# module "eks" {
#   source = "../../../modules/eks"
#
#   name_prefix                   = var.name_prefix
#   iam_role_permissions_boundary = var.iam_role_permissions_boundary
#
#   vpc_id                    = module.network.vpc_id
#   private_app_subnet_ids    = module.network.private_app_subnet_ids
#   node_desired_size         = var.node_desired_size
#   node_min_size             = var.node_min_size
#   node_max_size             = var.node_max_size
#   node_instance_types       = var.node_instance_types
#   endpoint_public_access    = var.eks_endpoint_public_access
#   endpoint_private_access   = var.eks_endpoint_private_access
#   public_access_cidrs       = var.eks_public_access_cidrs
#   enabled_cluster_log_types = var.enabled_cluster_log_types
# }

# 3단계 이후:
# - database
# - elasticache
# - ecr
# - s3
# - cloudfront
# - bastion
# - github_oidc
