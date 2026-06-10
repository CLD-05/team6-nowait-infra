# Redis primary 엔드포인트입니다.
# standalone 모드일 때 사용합니다.
# application.yml의 spring.data.redis.host에 입력합니다.
output "primary_endpoint_address" {
  description = "Redis primary endpoint address"
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

# Redis reader 엔드포인트입니다.
# replica가 있을 때 읽기 전용으로 사용합니다.
output "reader_endpoint_address" {
  description = "Redis reader endpoint address"
  value       = aws_elasticache_replication_group.this.reader_endpoint_address
}

# Redis 포트입니다.
output "port" {
  description = "Redis port"
  value       = 6379
}
