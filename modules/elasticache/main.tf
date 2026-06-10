# ----------------------------------------
# ElastiCache Security Group
# ----------------------------------------
#
# EKS 노드에서만 Redis 6379 포트 접근을 허용합니다.
# 외부 인터넷에서는 접근할 수 없습니다.
resource "aws_security_group" "redis" {
  name        = local.security_group_name
  description = "Allow Redis access from EKS nodes only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Redis from EKS nodes"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.eks_node_security_group_id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.security_group_name
  }
}

# ----------------------------------------
# ElastiCache Subnet Group
# ----------------------------------------
#
# ElastiCache가 위치할 서브넷 그룹입니다.
# private DB 서브넷에 배치하여 외부 접근을 차단합니다.
resource "aws_elasticache_subnet_group" "this" {
  name       = local.subnet_group_name
  subnet_ids = var.private_db_subnet_ids

  tags = {
    Name = local.subnet_group_name
  }
}

# ----------------------------------------
# ElastiCache Replication Group (Redis)
# ----------------------------------------
#
# replica_count = 0 이면 standalone (primary 1개만)
# replica_count >= 1 이면 async replication 구성
#
# dev:  replica_count = 0, multi_az = false
# prod: replica_count = 1, multi_az = true, automatic_failover = true
resource "aws_elasticache_replication_group" "this" {
  replication_group_id = local.replication_group_id
  description          = "NoWait Redis — ${var.name_prefix}"

  engine         = "redis"
  engine_version = var.engine_version
  node_type      = var.node_type
  port           = 6379

  # replica_count = 0이면 primary 1개만 생성됩니다.
  # replica_count >= 1이면 primary 1개 + replica N개가 생성됩니다.
  num_cache_clusters = var.replica_count + 1

  subnet_group_name  = aws_elasticache_subnet_group.this.name
  security_group_ids = [aws_security_group.redis.id]

  # Multi-AZ 설정입니다.
  # replica_count >= 1일 때만 의미가 있습니다.
  multi_az_enabled           = var.multi_az_enabled
  automatic_failover_enabled = var.automatic_failover_enabled

  # 저장 데이터 암호화입니다.
  at_rest_encryption_enabled = true

  # 전송 데이터 암호화입니다.
  # true로 설정 시 애플리케이션에서 TLS 연결이 필요합니다.
  transit_encryption_enabled = false

  maintenance_window       = var.maintenance_window
  snapshot_retention_limit = var.snapshot_retention_limit

  # 운영 중 삭제 방지는 환경별 tfvars에서 제어합니다.
  # dev는 false, prod는 true 권장합니다.
  apply_immediately = true

  tags = {
    Name = local.replication_group_id
  }
}
