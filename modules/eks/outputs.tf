# ----------------------------------------
# EKS Cluster
# ----------------------------------------

# platform-addons에서 EKS Add-ons, Helm 설치 시 클러스터 이름 참조
output "cluster_name" {
  description = "EKS 클러스터 이름"
  value       = aws_eks_cluster.main.name
}

# kubernetes provider 설정 시 API Server 주소로 사용
output "cluster_endpoint" {
  description = "EKS API Server 엔드포인트"
  value       = aws_eks_cluster.main.endpoint
}

# kubernetes provider 설정 시 클러스터 인증에 사용
output "cluster_certificate_authority_data" {
  description = "EKS 클러스터 CA 인증서 (base64)"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_version" {
  description = "EKS Kubernetes 버전"
  value       = aws_eks_cluster.main.version
}

# ----------------------------------------
# IAM Role
# ----------------------------------------

# 담당자 C가 Pod Identity Association 연결 시 사용
output "node_group_role_arn" {
  description = "EKS Node Group IAM Role ARN (platform-addons에서 Pod Identity 연결 시 사용)"
  value       = aws_iam_role.eks_node.arn
}
