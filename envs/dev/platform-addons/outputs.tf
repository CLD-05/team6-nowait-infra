# Add-ons를 설치할 대상 EKS Cluster 이름입니다.
output "cluster_name" {
  value = var.cluster_name
}

# 현재 환경 이름입니다.
output "environment" {
  value = var.environment
}

# IAM Role 생성 시 반드시 사용할 permissions boundary입니다.
output "iam_role_permissions_boundary" {
  value = var.iam_role_permissions_boundary
}

output "eks_addon_names" {
  value = module.addons.eks_addon_names
}

output "eks_addon_versions" {
  value = module.addons.eks_addon_versions
}

output "ebs_csi_role_arn" {
  value = module.addons.ebs_csi_role_arn
}

output "lbc_role_arn" {
  description = "AWS Load Balancer Controller Pod Identity IAM Role ARN"
  value       = module.addons.lbc_role_arn
}

output "lbc_policy_arn" {
  description = "AWS Load Balancer Controller IAM Policy ARN"
  value       = module.addons.lbc_policy_arn
}

output "lbc_helm_release_name" {
  description = "AWS Load Balancer Controller Helm release name"
  value       = module.addons.lbc_helm_release_name
}

output "metrics_server_helm_release_name" {
  description = "metrics-server Helm release name"
  value       = module.addons.metrics_server_helm_release_name
}

output "eso_helm_release_name" {
  description = "External Secrets Operator Helm release name"
  value       = module.addons.eso_helm_release_name
}