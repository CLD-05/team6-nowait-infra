locals {
  parameter_prefix = "/${var.team}/${var.project}/${var.environment}"

  app_parameters = {
    # ========================================
    # RDS
    # ========================================

    "/rds/host" = {
      type  = "String"
      value = var.rds_host
    }

    "/rds/port" = {
      type  = "String"
      value = var.rds_port
    }

    "/rds/database" = {
      type  = "String"
      value = var.rds_database
    }

    "/rds/username" = {
      type  = "SecureString"
      value = var.rds_username
    }

    "/rds/password" = {
      type  = "SecureString"
      value = var.rds_password
    }

    # ========================================
    # Redis
    # ========================================

    "/redis/host" = {
      type  = "String"
      value = var.redis_host
    }

    "/redis/port" = {
      type  = "String"
      value = var.redis_port
    }

    # ========================================
    # Application Secret
    # ========================================

    "/jwt/secret" = {
      type  = "SecureString"
      value = var.jwt_secret
    }

    # ========================================
    # AWS / S3 Image Upload Config
    # ========================================

    "/aws/region" = {
      type  = "String"
      value = var.aws_region
    }

    "/s3/image-bucket" = {
      type  = "String"
      value = var.s3_image_bucket
    }

    "/s3/image-prefix" = {
      type  = "String"
      value = var.s3_image_prefix
    }

    # ========================================
    # Application CORS Config
    # ========================================

    "/app/allowed-origins" = {
      type  = "String"
      value = join(",", var.app_allowed_origins)
    }
  }
}