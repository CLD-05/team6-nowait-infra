# ----------------------------------------
# ElastiCache Subnet Group
# ----------------------------------------
#
# ElastiCache가 위치할 서브넷 그룹입니다.
# private DB 서브넷에 배치하여 외부 접근을 차단합니다.
resource "aws_elasticache_subnet_group" "this" {
  name       = local.subnet_group_name
  subnet_ids = var.private_db_subnet_ids

  tags = merge(var.common_tags, {
    Name = local.subnet_group_name
  })
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
  description          = "NoWait Redis - ${var.name_prefix}"

  engine         = "redis"
  engine_version = var.engine_version
  node_type      = var.node_type
  port           = 6379

  # replica_count = 0이면 primary 1개만 생성됩니다.
  # replica_count >= 1이면 primary 1개 + replica N개가 생성됩니다.
  num_cache_clusters = var.replica_count + 1

  subnet_group_name = aws_elasticache_subnet_group.this.name

  # modules/sg에서 생성한 Redis SG를 사용합니다.
  security_group_ids = [var.security_group_id]

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

  apply_immediately = true

  tags = merge(var.common_tags, {
    Name = local.replication_group_id
  })
}
