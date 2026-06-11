variable "env" {
  description = "환경 이름 (dev, prod)"
  type        = string
}

variable "project" {
  description = "프로젝트 이름"
  type        = string
}

# ─── 네트워크 ───────────────────────────────────────────
variable "vpc_id" {
  description = "RDS를 배치할 VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "DB 서브넷 ID 목록 (Private Subnet)"
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "RDS 접근 허용할 SG ID 목록 (EKS Node SG, Bastion SG)"
  type        = list(string)
  default     = []
}

# ─── Aurora 클러스터 ─────────────────────────────────────
variable "engine_version" {
  description = "Aurora MySQL 버전"
  type        = string
  default     = "8.0.mysql_aurora.3.05.2"
}

variable "instance_class" {
  description = "Aurora 인스턴스 타입"
  type        = string
  default     = "db.t3.medium"
}

variable "instance_count" {
  description = "Aurora 인스턴스 수 (dev=1, prod=2 이상)"
  type        = number
  default     = 1
}

# ─── DB 접속 정보 ────────────────────────────────────────
variable "db_name" {
  description = "데이터베이스 이름"
  type        = string
}

variable "db_username" {
  description = "마스터 유저 이름"
  type        = string
  default     = "nowait_admin"
}

variable "port" {
  description = "MySQL 포트"
  type        = number
  default     = 3306
}

# ─── 백업 & 유지보수 ─────────────────────────────────────
variable "backup_retention_period" {
  description = "백업 보관 기간 (일)"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "백업 시간대 (UTC) → 한국시간 새벽 12~1시"
  type        = string
  default     = "15:00-16:00"
}

variable "maintenance_window" {
  description = "유지보수 시간대 (UTC)"
  type        = string
  default     = "Mon:16:00-Mon:17:00"
}

# ─── 보안 ────────────────────────────────────────────────
variable "deletion_protection" {
  description = "삭제 방지 (prod는 반드시 true)"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "삭제 시 최종 스냅샷 스킵 (dev=true, prod=false)"
  type        = bool
  default     = true
}

# ─── 모니터링 ────────────────────────────────────────────
variable "monitoring_interval" {
  description = "Enhanced Monitoring 간격 (초), 0이면 비활성화"
  type        = number
  default     = 60
}
