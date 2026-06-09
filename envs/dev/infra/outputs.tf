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
