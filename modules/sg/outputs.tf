output "alb_security_group_id" {
  description = "ALB Security Group ID"
  value       = aws_security_group.alb.id
}

output "eks_node_security_group_id" {
  description = "EKS Node Security Group ID"
  value       = aws_security_group.eks_node.id
}

output "rds_security_group_id" {
  description = "RDS Security Group ID"
  value       = aws_security_group.rds.id
}

output "redis_security_group_id" {
  description = "ElastiCache Redis Security Group ID"
  value       = aws_security_group.redis.id
}

output "bastion_security_group_id" {
  description = "Bastion Security Group ID"
  value = var.bastion_enabled ? aws_security_group.bastion[0].id : null
}
