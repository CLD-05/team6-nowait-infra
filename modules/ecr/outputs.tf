# Repository 이름 맵
# 외부에서 Repository 이름이 필요할 때 사용합니다.
#
# 예:
# module.ecr.repository_names["backend"]
# → "team6-nowait-dev-backend"
output "repository_names" {
  description = "Map of repository short name to full repository name"
  value = {
    for k, v in aws_ecr_repository.main : k => v.name
  }
}

# Repository URL 맵
# EKS Node Group의 이미지 pull, CI/CD push 주소로 사용합니다.
#
# 예:
# module.ecr.repository_urls["backend"]
# → "194722398200.dkr.ecr.ap-northeast-2.amazonaws.com/team6-nowait-dev-backend"
output "repository_urls" {
  description = "Map of repository short name to full repository URL"
  value = {
    for k, v in aws_ecr_repository.main : k => v.repository_url
  }
}

# Repository ARN 맵
# IAM Policy에서 ECR 접근 권한 부여 시 사용합니다.
#
# 예:
# module.ecr.repository_arns["backend"]
# → "arn:aws:ecr:ap-northeast-2:194722398200:repository/team6-nowait-dev-backend"
output "repository_arns" {
  description = "Map of repository short name to repository ARN"
  value = {
    for k, v in aws_ecr_repository.main : k => v.arn
  }
}
