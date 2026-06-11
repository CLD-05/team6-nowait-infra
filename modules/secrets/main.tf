# ========================================
# SSM Parameter Store
# RDS / Redis / Application Secrets
# ========================================

resource "aws_ssm_parameter" "app" {
  for_each = local.app_parameters

  name      = "${local.parameter_prefix}${each.key}"
  type      = each.value.type
  value     = each.value.value
  overwrite = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}${replace(each.key, "/", "-")}"
  })
}