locals {
  # Repository 이름 → 전체 이름 매핑
  # "backend" → "team6-nowait-dev-backend"
  repository_names = {
    for repo in var.repositories :
    repo => "${var.name_prefix}-${repo}"
  }

  # Lifecycle Policy JSON
  # lifecycle_policy_enabled = true일 때만 적용
  lifecycle_policy = jsonencode({
    rules = [
      # 규칙 1: 태그 없는 이미지 N일 후 삭제
      {
        rulePriority = 1
        description  = "Remove untagged images after ${var.untagged_image_days} days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.untagged_image_days
        }
        action = {
          type = "expire"
        }
      },
      # 규칙 2: 전체 이미지 최대 N개 초과 시 오래된 것부터 삭제
      {
        rulePriority = 2
        description  = "Keep only ${var.max_image_count} images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.max_image_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
