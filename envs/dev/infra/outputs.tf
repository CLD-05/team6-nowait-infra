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
  description = "생성된 VPC ID (담당자 B가 RDS, Redis, Bastion에서 참조)"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public Subnet ID 목록 (담당자 B Bastion, 담당자 C ALB에서 참조)"
  value       = module.network.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "Private App Subnet ID 목록"
  value       = module.network.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "Private DB Subnet ID 목록 (담당자 B RDS, Redis에서 참조)"
  value       = module.network.private_db_subnet_ids
}


# ----------------------------------------
# module "eks" 활성화 이후 추가
# ----------------------------------------
output "cluster_name" {
  description = "EKS 클러스터 이름 (담당자 C platform-addons에서 참조)"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API Server 엔드포인트 (담당자 C kubernetes provider에서 참조)"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "EKS 클러스터 CA 인증서 (담당자 C kubernetes provider에서 참조)"
  value       = module.eks.cluster_certificate_authority_data
}

output "node_group_role_arn" {
  description = "EKS Node Group IAM Role ARN (담당자 C Pod Identity에서 참조)"
  value       = module.eks.node_group_role_arn
}
