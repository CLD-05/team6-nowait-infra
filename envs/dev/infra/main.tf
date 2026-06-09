# 1단계: VPC / Subnet / NAT / Route Table
module "network" {
  source = "../../../modules/network"

  name_prefix              = var.name_prefix
  vpc_cidr                 = var.vpc_cidr
  az_count                 = var.az_count
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
  nat_gateway_mode         = var.nat_gateway_mode
}

# 2단계: EKS Cluster / Node Group / Access Entry
module "eks" {
  source = "../../../modules/eks"

  name_prefix                   = var.name_prefix
  iam_role_permissions_boundary = var.iam_role_permissions_boundary

  vpc_id                 = module.network.vpc_id
  private_app_subnet_ids = module.network.private_app_subnet_ids

  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  node_instance_types = var.node_instance_types

  eks_endpoint_public_access  = var.eks_endpoint_public_access
  eks_endpoint_private_access = var.eks_endpoint_private_access
  eks_public_access_cidrs     = var.eks_public_access_cidrs
  enabled_cluster_log_types   = var.enabled_cluster_log_types

  admin_principal_arns     = var.admin_principal_arns
  developer_principal_arns = var.developer_principal_arns
  viewer_principal_arns    = var.viewer_principal_arns
}
