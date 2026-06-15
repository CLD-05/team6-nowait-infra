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

  github_org       = var.github_org
  github_repo      = var.github_repo
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

  github_org       = var.github_org
  github_repo      = var.github_repo
  allowed_branches = ["main"]

  github_oidc_provider_arn = module.github_oidc_provider.oidc_provider_arn
  ecr_repository_arn       = var.ecr_repository_arn

  ecr_access = "push"

  iam_role_permissions_boundary = var.iam_role_permissions_boundary

  common_tags = local.default_tags
}