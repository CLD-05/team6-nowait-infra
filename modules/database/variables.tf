# 리소스 이름 prefix
variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

# RDS가 배치될 Private DB Subnet 목록
variable "private_db_subnet_ids" {
  description = "Private DB subnet IDs for RDS subnet group"
  type        = list(string)
}

# RDS에 연결할 Security Group ID
variable "security_group_id" {
  description = "RDS security group ID"
  type        = string
}

# RDS 엔진 종류
variable "engine" {
  description = "RDS engine"
  type        = string
  default     = "mysql"
}

# RDS 엔진 버전
variable "engine_version" {
  description = "RDS engine version"
  type        = string
  default     = "8.0"
}

# 초기 생성할 데이터베이스 이름
variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "nowait"
}

# RDS 관리자 계정명
variable "master_username" {
  description = "RDS master username"
  type        = string
  default     = "admin"
}

# RDS 관리자 비밀번호
variable "master_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

# RDS 인스턴스 타입
variable "instance_class" {
  description = "RDS instance class"
  type        = string
}

# 기본 스토리지 용량
variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

# 자동 확장 가능한 최대 스토리지 용량
variable "max_allocated_storage" {
  description = "Maximum allocated storage for autoscaling"
  type        = number
  default     = 100
}

# RDS 스토리지 타입
variable "storage_type" {
  description = "RDS storage type"
  type        = string
  default     = "gp3"
}

# Multi-AZ 사용 여부
variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
}

# Public 접근 허용 여부
variable "publicly_accessible" {
  description = "Whether RDS is publicly accessible"
  type        = bool
  default     = false
}

# 백업 보관 기간
variable "backup_retention_period" {
  description = "Backup retention days"
  type        = number
}

# 삭제 방지 여부
variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
}

# 삭제 시 최종 스냅샷 생략 여부
variable "skip_final_snapshot" {
  description = "Skip final snapshot when deleting RDS"
  type        = bool
}

# 최종 스냅샷 이름
variable "final_snapshot_identifier" {
  description = "Final snapshot identifier when skip_final_snapshot is false"
  type        = string
  default     = null
}

# 변경사항 즉시 적용 여부
variable "apply_immediately" {
  description = "Apply changes immediately"
  type        = bool
  default     = false
}

# 공통 태그
variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}