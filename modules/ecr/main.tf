# ECR Repository 생성
# local.repository_names 맵을 순회하며 Repository를 생성합니다.
#
# each.key   = "backend"
# each.value = "team6-nowait-dev-backend"
resource "aws_ecr_repository" "main" {
  for_each = local.repository_names

  name                 = each.value
  image_tag_mutability = var.image_tag_mutability

  # 이미지 push 시 자동 취약점 스캔
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  # 이미지 암호화 설정
  encryption_configuration {
    encryption_type = var.encryption_type
  }
}

# ECR Lifecycle Policy 적용
# lifecycle_policy_enabled = true인 경우에만 생성합니다.
resource "aws_ecr_lifecycle_policy" "main" {
  for_each = var.lifecycle_policy_enabled ? local.repository_names : {}

  repository = aws_ecr_repository.main[each.key].name
  policy     = local.lifecycle_policy
}
