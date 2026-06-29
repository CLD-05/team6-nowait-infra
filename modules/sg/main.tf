# ----------------------------------------
# RDS Security Group
#
# EKS 노드에서만 MySQL 3306 포트 접근을 허용합니다.
# ----------------------------------------
resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-rds-sg"
  description = "Allow MySQL from EKS nodes only"
  vpc_id      = var.vpc_id

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

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-redis-sg"
  })
}

# ----------------------------------------
# RDS access from EKS nodes
#
# 인라인 ingress 블록과 aws_security_group_rule(rds_from_bastion 등)을
# 같은 SG에 혼용하면 Terraform이 매 plan마다 인라인 블록 밖의 규칙을
# "관리 대상 아님"으로 보고 삭제하려는 충돌이 생긴다. 그래서 EKS 노드
# 규칙도 별도 aws_security_group_rule로 통일한다.
# ----------------------------------------
resource "aws_security_group_rule" "rds_from_eks" {
  type                     = "ingress"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = var.eks_source_security_group_id

  from_port   = 3306
  to_port     = 3306
  protocol    = "tcp"
  description = "MySQL from EKS nodes"
}

# ----------------------------------------
# Redis access from EKS nodes
#
# 위와 동일한 이유로 인라인 ingress 대신 별도 리소스로 분리.
# ----------------------------------------
resource "aws_security_group_rule" "redis_from_eks" {
  type                     = "ingress"
  security_group_id        = aws_security_group.redis.id
  source_security_group_id = var.eks_source_security_group_id

  from_port   = 6379
  to_port     = 6379
  protocol    = "tcp"
  description = "Redis from EKS nodes"
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
# ----------------------------------------
# EKS API Server access from Bastion
#
# prod private endpoint 접근을 위해 Bastion SG에서
# EKS Cluster Security Group의 443 포트 접근을 허용합니다.
# ----------------------------------------
resource "aws_security_group_rule" "eks_api_from_bastion" {
  count = var.bastion_enabled ? 1 : 0

  type                     = "ingress"
  security_group_id        = var.eks_source_security_group_id
  source_security_group_id = aws_security_group.bastion[0].id

  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  description = "Allow Bastion to access EKS private API endpoint"
}

# ----------------------------------------
# RDS access from Bastion
#
# 운영 디버깅(데이터 확인, 부하테스트 데이터 정리 등)을 위해
# Bastion SG에서 RDS 3306 포트 접근을 허용합니다.
# ----------------------------------------
resource "aws_security_group_rule" "rds_from_bastion" {
  count = var.bastion_enabled ? 1 : 0

  type                     = "ingress"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.bastion[0].id

  from_port   = 3306
  to_port     = 3306
  protocol    = "tcp"
  description = "Allow Bastion to access RDS MySQL for debugging"
}

# ----------------------------------------
# Redis access from Bastion
#
# 운영 디버깅(k6 부하테스트 후 캐시/큐 데이터 정리 등)을 위해
# Bastion SG에서 Redis 6379 포트 접근을 허용합니다.
# ----------------------------------------
resource "aws_security_group_rule" "redis_from_bastion" {
  count = var.bastion_enabled ? 1 : 0

  type                     = "ingress"
  security_group_id        = aws_security_group.redis.id
  source_security_group_id = aws_security_group.bastion[0].id

  from_port   = 6379
  to_port     = 6379
  protocol    = "tcp"
  description = "Allow Bastion to access ElastiCache Redis for debugging"
}