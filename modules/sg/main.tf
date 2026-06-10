# ----------------------------------------
# RDS Security Group
#
# EKS 노드에서만 MySQL 3306 포트 접근을 허용합니다.
# ----------------------------------------
resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-rds-sg"
  description = "Allow MySQL from EKS nodes only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from EKS nodes"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.eks_source_security_group_id]
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-rds-sg"
  })
}

# ----------------------------------------
# ElastiCache Security Group
#
# EKS 노드에서만 Redis 6379 포트 접근을 허용합니다.
# ----------------------------------------
resource "aws_security_group" "redis" {
  name        = "${var.name_prefix}-redis-sg"
  description = "Allow Redis from EKS nodes only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Redis from EKS nodes"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.eks_source_security_group_id]
  }
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-redis-sg"
  })
}

# ----------------------------------------
# Bastion Security Group
#
# SSM 중심 운영으로 SSH 인바운드 없음
# prod 환경에서만 사용합니다.
# ----------------------------------------
resource "aws_security_group" "bastion" {
  count = var.bastion_enabled ? 1 : 0
  name        = "${var.name_prefix}-bastion-sg"
  description = "Bastion SG - SSM only, no SSH inbound"
  vpc_id      = var.vpc_id

  # SSM은 아웃바운드만 있으면 동작합니다.
  # SSH 인바운드 규칙 없음
  egress {
    description = "Allow all outbound for SSM"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-bastion-sg"
  })
}
