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

# Redis AUTH 토큰입니다. auth_token_enabled = true일 때만 값이 있습니다.
# team6-nowait/{env}/redis Secrets Manager 시크릿에 REDIS_PASSWORD 키로
# 직접 넣어줘야 앱이 사용합니다 (이 모듈은 Secrets Manager에 직접 쓰지 않습니다).
output "auth_token" {
  description = "Redis AUTH token (null if auth_token_enabled = false)"
  value       = var.auth_token_enabled ? random_password.auth_token[0].result : null
  sensitive   = true
}
