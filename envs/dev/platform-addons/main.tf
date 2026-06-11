module "addons" {
  source = "../../../modules/addons"

  name_prefix                   = var.name_prefix
  environment                   = var.environment
  cluster_name                  = var.cluster_name
  iam_role_permissions_boundary = var.iam_role_permissions_boundary

  eks_addons                  = var.eks_addons
  addon_versions              = var.addon_versions
  enable_ebs_csi_pod_identity = var.enable_ebs_csi_pod_identity

  vpc_id = var.vpc_id

  lbc_chart_version            = var.lbc_chart_version
  metrics_server_chart_version = var.metrics_server_chart_version
  eso_chart_version            = var.eso_chart_version

  enable_eso_pod_identity  = var.enable_eso_pod_identity
  secrets_parameter_prefix = var.secrets_parameter_prefix
}