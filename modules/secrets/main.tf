# ========================================
# AWS Secrets Manager
# ========================================
#
# This module creates secret containers only.
# Do NOT store actual secret values in Terraform,
# because secret values can remain in tfstate.
# Actual values should be inserted using AWS Console or AWS CLI.

resource "aws_secretsmanager_secret" "this" {
  for_each = var.secrets

  name        = "${var.secret_prefix}/${each.value.name_suffix}"
  description = each.value.description

  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(var.common_tags, {
    Name = "${var.secret_prefix}/${each.value.name_suffix}"
  })
}