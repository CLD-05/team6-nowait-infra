# ========================================
# GitHub OIDC Provider
# ========================================

module "github_oidc_provider" {
  source = "../../../modules/github_oidc_provider"

  name_prefix = var.name_prefix

  common_tags = local.default_tags
}

# ========================================
# GitHub Actions Role - dev
# develop branch에서 dev 이미지 push 권한
# ========================================
module "github_oidc_role_dev" {
  source = "../../../modules/github_oidc_role"

  name_prefix      = var.name_prefix
  role_name_suffix = "dev"

  github_org  = var.github_org
  github_repo = var.github_repo

  # GitHub Environment 기반으로 OIDC subject를 제한
  github_environment = "development"

  # github_environment를 쓰면 allowed_branches는 trust policy에 사용되지 않음
  allowed_branches = ["develop"]

  github_oidc_provider_arn = module.github_oidc_provider.oidc_provider_arn
  ecr_repository_arn       = var.ecr_repository_arn

  ecr_access = "push"

  iam_role_permissions_boundary = var.iam_role_permissions_boundary

  common_tags = local.default_tags
}

# ========================================
# GitHub Actions Role - prod
# main branch에서 prod 이미지 push/promote 권한
# ========================================
module "github_oidc_role_prod" {
  source = "../../../modules/github_oidc_role"

  name_prefix      = var.name_prefix
  role_name_suffix = "prod"

  github_org  = var.github_org
  github_repo = var.github_repo

  github_environment = "production"
  allowed_branches   = ["main"]

  github_oidc_provider_arn = module.github_oidc_provider.oidc_provider_arn
  ecr_repository_arn       = var.ecr_repository_arn

  ecr_access = "push"

  iam_role_permissions_boundary = var.iam_role_permissions_boundary

  common_tags = local.default_tags
}

# ========================================
# Prod Frontend Deploy Policy (S3 sync + CloudFront invalidation)
# ========================================
# frontend-prod-deploy.yml 이 prod GitHub OIDC role 로 실행하는
#   - aws s3 sync frontend/dist s3://<bucket> --delete
#   - aws cloudfront create-invalidation --distribution-id <id> --paths "/*"
# 에 필요한 최소 권한을 prod role 에 추가한다.
# 변수가 비어 있으면 정책을 만들지 않으므로(count=0) 기존 동작에 영향 없음.

locals {
  enable_prod_frontend_deploy = var.prod_frontend_bucket_name != "" && var.prod_cloudfront_distribution_id != ""

  prod_frontend_bucket_arn = "arn:aws:s3:::${var.prod_frontend_bucket_name}"
  prod_cloudfront_arn      = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${var.prod_cloudfront_distribution_id}"
}

data "aws_iam_policy_document" "prod_frontend_deploy" {
  count = local.enable_prod_frontend_deploy ? 1 : 0

  # 정적 파일 업로드/교체/삭제 (sync --delete)
  statement {
    sid    = "AllowFrontendObjectWrite"
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetObject"
    ]

    resources = ["${local.prod_frontend_bucket_arn}/*"]
  }

  # sync 시 기존 객체 목록 비교(--delete) 에 필요
  statement {
    sid    = "AllowFrontendBucketList"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [local.prod_frontend_bucket_arn]
  }

  # 배포 후 CloudFront 캐시 무효화
  statement {
    sid    = "AllowCloudFrontInvalidation"
    effect = "Allow"

    actions = [
      "cloudfront:CreateInvalidation",
      "cloudfront:GetInvalidation"
    ]

    resources = [local.prod_cloudfront_arn]
  }
}

resource "aws_iam_policy" "prod_frontend_deploy" {
  count = local.enable_prod_frontend_deploy ? 1 : 0

  name   = "${var.name_prefix}-prod-github-actions-frontend-deploy-policy"
  policy = data.aws_iam_policy_document.prod_frontend_deploy[0].json

  tags = merge(local.default_tags, {
    Name       = "${var.name_prefix}-prod-github-actions-frontend-deploy-policy"
    DeployRole = "prod"
  })
}

resource "aws_iam_role_policy_attachment" "prod_frontend_deploy" {
  count = local.enable_prod_frontend_deploy ? 1 : 0

  role       = module.github_oidc_role_prod.role_name
  policy_arn = aws_iam_policy.prod_frontend_deploy[0].arn
}