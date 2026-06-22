output "cluster_name" {
  description = "EKS Cluster name"
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "EKS Cluster ARN"
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "EKS API Server endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "EKS Cluster CA data"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "EKS Cluster Security Group ID"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "node_security_group_id" {
  description = "Security Group ID used for EKS node communication"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "node_group_name" {
  description = "EKS Managed Node Group name"
  value       = aws_eks_node_group.main.node_group_name
}

output "cluster_role_arn" {
  description = "EKS Cluster IAM Role ARN"
  value       = aws_iam_role.cluster.arn
}

output "node_role_arn" {
  description = "EKS Node IAM Role ARN"
  value       = aws_iam_role.node.arn
}

output "oidc_provider_url" {
  description = "EKS OIDC issuer URL (IRSA용 — platform-addons에서 사용)"
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}