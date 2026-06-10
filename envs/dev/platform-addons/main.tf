module "addons" {
  source = "../../../modules/addons"

  name_prefix                   = var.name_prefix
  environment                   = var.environment
  cluster_name                  = var.cluster_name
  iam_role_permissions_boundary = var.iam_role_permissions_boundary

  eks_addons                  = var.eks_addons
  addon_versions              = var.addon_versions
  enable_ebs_csi_pod_identity = var.enable_ebs_csi_pod_identity
}