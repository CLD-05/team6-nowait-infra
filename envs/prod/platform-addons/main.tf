# 이 파일은 envs/dev/platform-addons 또는 envs/prod/platform-addons의 진입점입니다.
# platform-addons는 EKS Cluster가 먼저 생성된 뒤 실행합니다.
# 현재는 PR 1 공통 구조 단계라 실제 module 호출은 주석 처리해둡니다.

# module "addons" {
#   source = "../../../modules/addons"
#
#   name_prefix                   = var.name_prefix
#   cluster_name                  = var.cluster_name
#
#   # Add-on / Pod Identity 관련 IAM Role 생성 시 필수
#   iam_role_permissions_boundary = var.iam_role_permissions_boundary
#
#   enable_aws_load_balancer_controller = var.enable_aws_load_balancer_controller
#   enable_argocd                       = var.enable_argocd
#   enable_metrics_server               = var.enable_metrics_server
#   enable_external_secrets             = var.enable_external_secrets
#
#   # 앱 배포 후 2차 단계에서 활성화
#   enable_kube_prometheus_stack = var.enable_kube_prometheus_stack
# }
