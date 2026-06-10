# EKS Cluster 이름입니다.
output "cluster_name" {
  description = "EKS Cluster name"
  value       = aws_eks_cluster.this.name
}

# EKS Cluster ARN입니다.
output "cluster_arn" {
  description = "EKS Cluster ARN"
  value       = aws_eks_cluster.this.arn
}

# EKS API Server endpoint입니다.
output "cluster_endpoint" {
  description = "EKS API Server endpoint"
  value       = aws_eks_cluster.this.endpoint
}

# EKS Cluster CA data입니다.
# Kubernetes/Helm provider 설정에서 사용할 수 있습니다.
output "cluster_certificate_authority_data" {
  description = "EKS Cluster CA data"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

# EKS Cluster Security Group ID입니다.
output "cluster_security_group_id" {
  description = "EKS Cluster Security Group ID"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

# Node Security Group ID입니다.
#
# 단순화를 위해 cluster_security_group_id를 같이 내보냅니다.
# 이후 RDS/Redis 접근 허용 source security group으로 사용할 수 있습니다.
output "node_security_group_id" {
  description = "Security Group ID used for EKS node communication"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

# Node Group 이름입니다.
output "node_group_name" {
  description = "EKS Managed Node Group name"
  value       = aws_eks_node_group.main.node_group_name
}

# EKS Cluster IAM Role ARN입니다.
output "cluster_role_arn" {
  description = "EKS Cluster IAM Role ARN"
  value       = aws_iam_role.cluster.arn
}

# EKS Node IAM Role ARN입니다.
output "node_role_arn" {
  description = "EKS Node IAM Role ARN"
  value       = aws_iam_role.node.arn
}