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
