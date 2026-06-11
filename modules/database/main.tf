locals {
  name = "${var.project}-${var.env}"
}

# ─── 보안 그룹 ───────────────────────────────────────────
# RDS에 접근 가능한 대상을 제한
resource "aws_security_group" "rds" {
  name        = "${local.name}-rds-sg"
  description = "Security Group for Aurora MySQL - ${local.name}"
  vpc_id      = var.vpc_id

  # EKS Node SG, Bastion SG 등 허용된 곳에서만 3306 접근 가능
  dynamic "ingress" {
    for_each = var.allowed_security_group_ids
    content {
      from_port       = var.port
      to_port         = var.port
      protocol        = "tcp"
      security_groups = [ingress.value]
      description     = "MySQL from ${ingress.value}"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${local.name}-rds-sg"
    Env     = var.env
    Project = var.project
  }
}

# ─── 서브넷 그룹 ─────────────────────────────────────────
# Aurora가 배치될 Private Subnet 지정
resource "aws_db_subnet_group" "this" {
  name        = "${local.name}-db-subnet-group"
  description = "Aurora subnet group for ${local.name}"
  subnet_ids  = var.subnet_ids

  tags = {
    Name    = "${local.name}-db-subnet-group"
    Env     = var.env
    Project = var.project
  }
}

# ─── 파라미터 그룹 (클러스터 레벨) ──────────────────────
resource "aws_rds_cluster_parameter_group" "this" {
  name        = "${local.name}-aurora-cluster-pg"
  family      = "aurora-mysql8.0"
  description = "Cluster parameter group for ${local.name}"

  # 한국어 데이터 저장을 위한 UTF8MB4 설정
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }

  # 슬로우 쿼리 로깅 (1초 이상)
  parameter {
    name  = "long_query_time"
    value = "1"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  tags = {
    Name    = "${local.name}-aurora-cluster-pg"
    Env     = var.env
    Project = var.project
  }
}

# ─── 파라미터 그룹 (인스턴스 레벨) ──────────────────────
resource "aws_db_parameter_group" "this" {
  name        = "${local.name}-aurora-instance-pg"
  family      = "aurora-mysql8.0"
  description = "Instance parameter group for ${local.name}"

  tags = {
    Name    = "${local.name}-aurora-instance-pg"
    Env     = var.env
    Project = var.project
  }
}

# ─── Enhanced Monitoring IAM Role ────────────────────────
resource "aws_iam_role" "rds_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0
  name  = "${local.name}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "monitoring.rds.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  count      = var.monitoring_interval > 0 ? 1 : 0
  role       = aws_iam_role.rds_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# ─── Aurora 클러스터 ─────────────────────────────────────
# 비밀번호는 AWS가 Secrets Manager에 자동 생성/관리
resource "aws_rds_cluster" "this" {
  cluster_identifier = "${local.name}-aurora-cluster"
  engine             = "aurora-mysql"
  engine_version     = var.engine_version

  database_name   = var.db_name
  master_username = var.db_username

  # 비밀번호를 코드에 직접 쓰지 않고 AWS Secrets Manager가 자동 관리
  manage_master_user_password = true

  db_subnet_group_name            = aws_db_subnet_group.this.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.name
  vpc_security_group_ids          = [aws_security_group.rds.id]
  port                            = var.port

  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.backup_window
  preferred_maintenance_window = var.maintenance_window

  storage_encrypted   = true
  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot

  enabled_cloudwatch_logs_exports = ["audit", "error", "slowquery"]

  tags = {
    Name    = "${local.name}-aurora-cluster"
    Env     = var.env
    Project = var.project
  }
}

# ─── Aurora 인스턴스 ─────────────────────────────────────
# count로 dev=1개, prod=2개 이상 조절
resource "aws_rds_cluster_instance" "this" {
  count = var.instance_count

  identifier         = "${local.name}-aurora-instance-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.this.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version

  db_parameter_group_name = aws_db_parameter_group.this.name
  db_subnet_group_name    = aws_db_subnet_group.this.name

  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring[0].arn : null

  performance_insights_enabled = true

  # 마이너 버전 자동 업그레이드 (dev는 허용, prod는 false 권장)
  auto_minor_version_upgrade = var.env == "dev" ? true : false

  tags = {
    Name    = "${local.name}-aurora-instance-${count.index + 1}"
    Env     = var.env
    Project = var.project
  }

  # false로 설정 시 퍼블릭 접근 차단 (보안상 필수)
  publicly_accessible = false

}
