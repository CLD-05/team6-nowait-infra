# ----------------------------------------
# ALB Security Group
#
# 인터넷에서 HTTP/HTTPS 트래픽을 받습니다.
# ----------------------------------------
resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Allow HTTP/HTTPS from internet"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-alb-sg"
  }
}

# ----------------------------------------
# EKS Node Security Group
#
# ALB에서 오는 트래픽과 노드 간 통신을 허용합니다.
# ----------------------------------------
resource "aws_security_group" "eks_node" {
  name        = "${var.name_prefix}-eks-node-sg"
  description = "EKS worker node security group"
  vpc_id      = var.vpc_id

  # ALB에서 노드로 트래픽 허용
  ingress {
    description     = "From ALB"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.alb.id]
  }

  # 노드 간 통신 허용
  ingress {
    description = "Node to node"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-eks-node-sg"
  }
}

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
    security_groups = [aws_security_group.eks_node.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-rds-sg"
  }
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
    security_groups = [aws_security_group.eks_node.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-redis-sg"
  }
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

  tags = {
    Name = "${var.name_prefix}-bastion-sg"
  }
}
