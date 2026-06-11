locals {
  parameter_prefix = "/${var.team}/${var.project}/${var.environment}"

  app_parameters = {
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

    "/redis/host" = {
      type  = "String"
      value = var.redis_host
    }

    "/redis/port" = {
      type  = "String"
      value = var.redis_port
    }

    "/jwt/secret" = {
      type  = "SecureString"
      value = var.jwt_secret
    }
  }
}