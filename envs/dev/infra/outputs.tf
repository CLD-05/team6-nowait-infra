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
# module "network" 활성화 이후 추가
# ----------------------------------------
output "vpc_id" {
  description = "생성된 VPC ID "
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
# module "eks" 활성화 이후 추가
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
  description = "실제 EKS Cluster Security Group ID"
  value       = module.eks.cluster_security_group_id
}

output "eks_node_security_group_id" {
  description = "RDS/Redis 접근 허용 source로 사용하는 실제 EKS Security Group ID"
  value       = module.eks.node_security_group_id
}

output "eks_node_group_name" {
  description = "EKS Managed Node Group 이름"
  value       = module.eks.node_group_name
}

# ----------------------------------------
# module "sg" 활성화 이후 추가
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
  description = "Bastion Security Group ID. bastion이 비활성화되면 null입니다."
  value       = module.sg.bastion_security_group_id
}

# ----------------------------------------
# module "elasticache" 활성화 이후 추가
# ----------------------------------------
output "redis_primary_endpoint" {
  description = "Redis primary endpoint — application.yml spring.data.redis.host에 입력"
  value       = module.elasticache.primary_endpoint_address
}

output "redis_port" {
  description = "Redis port"
  value       = module.elasticache.port
}

# ----------------------------------------
# module "github_oidc" 활성화 이후 추가
# ----------------------------------------

output "github_actions_role_name" {
  description = "Dev GitHub Actions IAM Role name"
  value       = module.github_oidc_role.role_name
}

output "github_actions_role_arn" {
  description = "Dev GitHub Actions IAM Role ARN"
  value       = module.github_oidc_role.role_arn
}

output "github_actions_ecr_policy_arn" {
  description = "Dev GitHub Actions ECR Policy ARN"
  value       = module.github_oidc_role.ecr_policy_arn
}
