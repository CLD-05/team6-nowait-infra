# ========================================
# GitHub OIDC Provider
# ========================================

module "github_oidc_provider" {
  source = "../../../modules/github_oidc_provider"

  name_prefix = var.name_prefix

  common_tags = local.default_tags
}