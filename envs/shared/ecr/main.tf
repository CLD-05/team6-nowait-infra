# ========================================
# ECR
# Shared container image repository
# ========================================

module "ecr" {
  source = "../../../modules/ecr"

  repository_name      = var.repository_name
  image_tag_mutability = var.image_tag_mutability
  scan_on_push         = var.scan_on_push
  force_delete         = var.force_delete

  untagged_image_expire_days = var.untagged_image_expire_days
  keep_recent_image_count    = var.keep_recent_image_count

  common_tags = local.default_tags
}