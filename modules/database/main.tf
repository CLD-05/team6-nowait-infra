# ========================================
# Locals
# ========================================
locals {
  db_identifier          = "${var.name_prefix}-rds"
  subnet_group_name      = "${var.name_prefix}-rds-subnet-group"
  parameter_group_name   = "${var.name_prefix}-mysql-parameter-group"
  final_snapshot_id      = var.skip_final_snapshot ? null : coalesce(var.final_snapshot_identifier, "${var.name_prefix}-rds-final-snapshot")
}

# ========================================
# DB Subnet Group
# ========================================
resource "aws_db_subnet_group" "this" {
  name        = local.subnet_group_name
  description = "RDS subnet group for ${var.name_prefix}"

  subnet_ids = var.private_db_subnet_ids

  tags = merge(var.common_tags, {
    Name = local.subnet_group_name
  })
}

# ========================================
# DB Parameter Group
# ========================================
resource "aws_db_parameter_group" "this" {
  name        = local.parameter_group_name
  description = "MySQL parameter group for ${var.name_prefix}"
  family      = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }

  tags = merge(var.common_tags, {
    Name = local.parameter_group_name
  })
}

# ========================================
# RDS Instance
# ========================================
resource "aws_db_instance" "this" {
  identifier = local.db_identifier

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  db_name  = var.db_name
  username = var.master_username
  password = var.master_password

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.security_group_id]
  parameter_group_name   = aws_db_parameter_group.this.name

  multi_az            = var.multi_az
  publicly_accessible = var.publicly_accessible

  backup_retention_period = var.backup_retention_period

  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = local.final_snapshot_id

  apply_immediately = var.apply_immediately

  auto_minor_version_upgrade = false
  copy_tags_to_snapshot      = true

  tags = merge(var.common_tags, {
    Name = local.db_identifier
  })
}