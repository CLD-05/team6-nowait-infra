module "addons" {
  source = "../../../modules/addons"

  region      = var.region
  team        = var.team
  project     = var.project
  name_prefix = var.name_prefix
  environment = var.environment

  cluster_name                  = var.cluster_name
  iam_role_permissions_boundary = var.iam_role_permissions_boundary

  eks_addons                  = var.eks_addons
  addon_versions              = var.addon_versions
  enable_ebs_csi_pod_identity = var.enable_ebs_csi_pod_identity

  vpc_id = var.vpc_id

  lbc_chart_version            = var.lbc_chart_version
  metrics_server_chart_version = var.metrics_server_chart_version
  eso_chart_version            = var.eso_chart_version

  # Argo CD
  enable_argocd        = var.enable_argocd
  argocd_chart_version = var.argocd_chart_version
  argocd_values_file   = "${path.module}/helm-values/argocd-values.yaml"

  # External Secrets Operator Pod Identity
  enable_eso_pod_identity      = var.enable_eso_pod_identity
  external_secrets_secret_arns = var.external_secrets_secret_arns

  # NoWait API Pod Identity
  enable_nowait_api_pod_identity = var.enable_nowait_api_pod_identity
  nowait_api_namespace           = var.nowait_api_namespace
  nowait_api_service_account     = var.nowait_api_service_account
  image_bucket_arn               = var.image_bucket_arn

  # KEDA
  enable_keda        = var.enable_keda
  keda_chart_version = var.keda_chart_version
  keda_values_file   = "${path.module}/helm-values/keda-values.yaml"

  # Karpenter
  enable_karpenter        = var.enable_karpenter
  karpenter_chart_version = var.karpenter_chart_version
  karpenter_values_file   = "${path.module}/helm-values/karpenter-values.yaml"

  # Monitoring
  enable_kube_prometheus_stack        = var.enable_kube_prometheus_stack
  kube_prometheus_stack_chart_version = var.kube_prometheus_stack_chart_version
  kube_prometheus_stack_values_file   = "${path.module}/helm-values/kube-prometheus-stack-values.yaml"
  nowait_dashboard_json_file          = "${path.module}/dashboards/nowait-overview.json"
}