# ========================================
# Common
# ========================================

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "team" {
  description = "Team tag value"
  type        = string
  default     = "team6"
}

variable "project" {
  description = "Project tag value"
  type        = string
  default     = "nowait"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "global"
}

variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
  default     = "team6-nowait"
}

# ========================================
# GitHub Actions OIDC Roles
# ========================================

variable "github_org" {
  description = "GitHub organization or user name"
  type        = string
  default     = "CLD-05"
}

variable "github_repo" {
  description = "GitHub repository name for application repository"
  type        = string
  default     = "team6-nowait-app"
}

variable "ecr_repository_arn" {
  description = "Shared ECR repository ARN"
  type        = string
}

variable "iam_role_permissions_boundary" {
  description = "Required permissions boundary for IAM roles created by students"
  type        = string
  default     = "arn:aws:iam::194722398200:policy/TeamRuntimeBoundary"
}

# ========================================
# Prod Frontend Deploy (S3 + CloudFront)
# ========================================
# frontend-prod-deploy.yml 워크플로우가 prod GitHub OIDC role 로
# `aws s3 sync --delete` + `cloudfront create-invalidation` 을 수행한다.
# github_oidc_role 모듈은 ECR 권한만 부여하므로, 프론트 prod 배포에
# 필요한 S3/CloudFront 권한은 이 스택에서 별도 정책으로 붙인다.
# 두 값이 모두 채워졌을 때만 정책을 생성한다(둘 중 하나라도 비면 생성 안 함).

variable "prod_frontend_bucket_name" {
  description = "Production frontend S3 bucket name (s3 sync 대상). 예: team6-nowait-prod-frontend-194722398200"
  type        = string
  default     = ""
}

variable "prod_cloudfront_distribution_id" {
  description = "Production frontend CloudFront distribution ID (CreateInvalidation 대상). 예: E15S7A5BISZTN7"
  type        = string
  default     = ""
}