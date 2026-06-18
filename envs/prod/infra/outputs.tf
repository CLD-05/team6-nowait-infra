# 현재 적용 중인 환경 이름입니다.
output "environment" {
  value = var.environment
}

# 리소스 이름 prefix입니다.
output "name_prefix" {
  value = var.name_prefix
}

# 실제 선택된 AZ 목록입니다.
output "selected_availability_zones" {
  value = local.azs
}

# 현재 AWS 계정 ID입니다.
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

# IAM Role 생성 시 반드시 사용할 permissions boundary입니다.
output "iam_role_permissions_boundary" {
  value = var.iam_role_permissions_boundary
}

# ----------------------------------------
# Network
# ----------------------------------------
output "vpc_id" {
  description = "생성된 VPC ID"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public Subnet ID 목록"
  value       = module.network.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "Private App Subnet ID 목록"
  value       = module.network.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "Private DB Subnet ID 목록"
  value       = module.network.private_db_subnet_ids
}

output "nat_gateway_ids" {
  value = module.network.nat_gateway_ids
}

# ----------------------------------------
# EKS
# ----------------------------------------
output "eks_cluster_name" {
  description = "EKS Cluster 이름"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster API Server Endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "EKS Cluster Security Group ID"
  value       = module.eks.cluster_security_group_id
}

output "eks_node_security_group_id" {
  description = "RDS/Redis 접근 허용 source로 사용하는 EKS Security Group ID"
  value       = module.eks.node_security_group_id
}

output "eks_node_group_name" {
  description = "EKS Managed Node Group 이름"
  value       = module.eks.node_group_name
}

# ----------------------------------------
# Security Group
# ----------------------------------------
output "rds_security_group_id" {
  description = "RDS Security Group ID"
  value       = module.sg.rds_security_group_id
}

output "redis_security_group_id" {
  description = "Redis Security Group ID"
  value       = module.sg.redis_security_group_id
}

output "bastion_security_group_id" {
  description = "Bastion Security Group ID"
  value       = module.sg.bastion_security_group_id
}

# ----------------------------------------
# Bastion
# ----------------------------------------
output "bastion_instance_id" {
  description = "Bastion EC2 instance ID"
  value       = var.bastion_enabled ? module.bastion[0].instance_id : null
}

output "bastion_role_arn" {
  description = "Bastion IAM Role ARN"
  value       = var.bastion_enabled ? module.bastion[0].role_arn : null
}

# ----------------------------------------
# RDS
# ----------------------------------------
output "rds_instance_id" {
  description = "RDS instance ID"
  value       = module.database.db_instance_id
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.database.db_endpoint
}

output "rds_address" {
  description = "RDS address"
  value       = module.database.db_address
}

output "rds_port" {
  description = "RDS port"
  value       = module.database.db_port
}

output "rds_db_name" {
  description = "RDS database name"
  value       = module.database.db_name
}

output "rds_master_user_secret_arn" {
  description = "RDS managed master user secret ARN"
  value       = module.database.master_user_secret_arn
}

# ----------------------------------------
# Redis
# ----------------------------------------
output "redis_primary_endpoint" {
  description = "Redis primary endpoint"
  value       = module.elasticache.primary_endpoint_address
}

output "redis_port" {
  description = "Redis port"
  value       = module.elasticache.port
}

# terraform output -raw redis_auth_token 으로 값을 꺼내서
# team6-nowait/prod/redis 시크릿에 REDIS_PASSWORD 키로 직접 넣어야 한다.
output "redis_auth_token" {
  description = "Redis AUTH token - put into team6-nowait/prod/redis as REDIS_PASSWORD"
  value       = module.elasticache.auth_token
  sensitive   = true
}

# ----------------------------------------
# Secrets Manager
# ----------------------------------------
output "secret_prefix" {
  description = "Secrets Manager secret prefix"
  value       = module.secrets.secret_prefix
}

output "secret_names" {
  description = "Secrets Manager secret names"
  value       = module.secrets.secret_names
}

output "secret_arns" {
  description = "Secrets Manager secret ARNs"
  value       = module.secrets.secret_arns
}

# ----------------------------------------
# S3
# ----------------------------------------
output "image_bucket_id" {
  description = "Image S3 bucket ID"
  value       = module.s3.image_bucket_id
}

output "image_bucket_arn" {
  description = "Image S3 bucket ARN"
  value       = module.s3.image_bucket_arn
}

output "image_bucket_domain_name" {
  description = "Image S3 bucket regional domain name"
  value       = module.s3.image_bucket_domain_name
}