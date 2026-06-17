# 공통 태그
variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

# 리소스 이름 prefix입니다.
# 예: team6-nowait-dev
variable "name_prefix" {
  description = "Common resource name prefix. Must start with team6-."
  type        = string

  validation {
    condition     = startswith(var.name_prefix, "team6-")
    error_message = "name_prefix must start with team6-."
  }
}

# ElastiCache가 위치할 VPC ID입니다.
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

# ElastiCache가 위치할 DB 서브넷 ID 목록입니다.
variable "private_db_subnet_ids" {
  description = "Private DB subnet IDs for ElastiCache"
  type        = list(string)
}

# modules/sg에서 생성한 Redis Security Group ID입니다.
variable "security_group_id" {
  description = "Redis security group ID from modules/sg"
  type        = string
}

# Redis 노드 타입입니다.
# dev는 cache.t3.micro, prod는 cache.r7g.large 권장합니다.
variable "node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t3.micro"
}

# Redis 엔진 버전입니다.
variable "engine_version" {
  description = "Redis engine version"
  type        = string
  default     = "7.1"
}

# Redis replica 수입니다.
# dev는 0 (standalone), prod는 1 이상 권장합니다.
variable "replica_count" {
  description = "Number of Redis replicas. 0 = standalone."
  type        = number
  default     = 0
}

# Multi-AZ 활성화 여부입니다.
# replica_count >= 1일 때만 의미가 있습니다.
variable "multi_az_enabled" {
  description = "Enable Multi-AZ for ElastiCache"
  type        = bool
  default     = false
}

# 자동 failover 활성화 여부입니다.
# replica_count >= 1일 때만 활성화 가능합니다.
variable "automatic_failover_enabled" {
  description = "Enable automatic failover. Requires replica_count >= 1."
  type        = bool
  default     = false
}

# 유지보수 시간 설정입니다.
variable "maintenance_window" {
  description = "Weekly maintenance window"
  type        = string
  default     = "sun:05:00-sun:06:00"
}

# 스냅샷 보관 기간입니다.
# dev는 0 (비활성), prod는 7 이상 권장합니다.
variable "snapshot_retention_limit" {
  description = "Snapshot retention days. 0 = disabled."
  type        = number
  default     = 0
}

# 전송 데이터 암호화(TLS) 활성화 여부입니다.
# true로 설정하려면 auth_token_enabled도 true여야 합니다 (AWS 제약).
# dev: false (네트워크 격리에만 의존), prod: true 권장.
variable "transit_encryption_enabled" {
  description = "Enable TLS for data in transit. Required if auth_token_enabled is true."
  type        = bool
  default     = false
}

# AUTH 토큰(비밀번호) 활성화 여부입니다.
# true이면 모듈이 random_password로 토큰을 생성해서 auth_token output으로 내보냅니다.
# dev: false (네트워크 격리로만 방어), prod: true 권장 — Redis에 refresh token/
# access token 블랙리스트가 저장되므로 네트워크 격리만으로는 방어선이 한 겹뿐입니다.
variable "auth_token_enabled" {
  description = "Enable Redis AUTH token. Requires transit_encryption_enabled = true."
  type        = bool
  default     = false
}
