# AWS 리전입니다.
variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

# 학원 정책상 Team 태그는 반드시 team6이어야 합니다.
variable "team" {
  description = "Team tag value. Must be team6."
  type        = string
  default     = "team6"

  validation {
    condition     = var.team == "team6"
    error_message = "team must be team6 because academy policy requires Team=team6."
  }
}

# 프로젝트 이름 태그입니다.
variable "project" {
  description = "Project tag value"
  type        = string
  default     = "nowait"
}

# 현재 환경 이름입니다. dev 또는 prod만 허용합니다.
variable "environment" {
  description = "Environment name. Example: dev, prod"
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be dev or prod."
  }
}

# 리소스 이름 앞에 붙일 공통 prefix입니다.
# IAM Role 이름도 team6-* 형태여야 하므로 team6-로 시작하도록 강제합니다.
variable "name_prefix" {
  description = "Common resource name prefix. Must start with team6-."
  type        = string

  validation {
    condition     = startswith(var.name_prefix, "team6-")
    error_message = "name_prefix must start with team6-."
  }
}

# 학생이 만드는 IAM Role에 반드시 붙여야 하는 permissions boundary입니다.
# EKS Role, Node Role, Bastion Role, Pod Identity Role, GitHub OIDC Role 등에 사용합니다.
variable "iam_role_permissions_boundary" {
  description = "Required permissions boundary for IAM roles created by students."
  type        = string
  default     = "arn:aws:iam::194722398200:policy/TeamRuntimeBoundary"
}

# VPC CIDR입니다.
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

# 사용할 AZ 개수입니다. 기본 2개를 사용합니다.
variable "az_count" {
  description = "Number of Availability Zones to use"
  type        = number
  default     = 2
}

# Public subnet CIDR 목록입니다. ALB, NAT Gateway가 위치합니다.
variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
}

# Private App subnet CIDR 목록입니다. EKS Node와 애플리케이션 Pod가 위치합니다.
variable "private_app_subnet_cidrs" {
  description = "Private app subnet CIDR blocks"
  type        = list(string)
}

# Private DB subnet CIDR 목록입니다. RDS와 Redis가 위치합니다.
variable "private_db_subnet_cidrs" {
  description = "Private DB subnet CIDR blocks"
  type        = list(string)
}

# NAT Gateway 구성 방식입니다.
# dev는 비용 절감을 위해 single, prod는 비용 허용 시 per_az를 고려합니다.
variable "nat_gateway_mode" {
  description = "NAT gateway mode. Example: single, per_az, none"
  type        = string
  default     = "single"

  validation {
    condition     = contains(["single", "per_az", "none"], var.nat_gateway_mode)
    error_message = "nat_gateway_mode must be one of: single, per_az, none."
  }
}


# EKS Kubernetes 버전입니다.
# 이번 프로젝트에서는 1.34로 고정합니다.
variable "eks_cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.34"
}

# EKS Managed Node Group의 desired size입니다.
variable "node_desired_size" {
  description = "EKS managed node group desired size"
  type        = number
}

# EKS Managed Node Group의 최소 노드 수입니다.
variable "node_min_size" {
  description = "EKS managed node group min size"
  type        = number
}

# EKS Managed Node Group의 최대 노드 수입니다.
variable "node_max_size" {
  description = "EKS managed node group max size"
  type        = number
}

# Worker Node EC2 인스턴스 타입입니다.
variable "node_instance_types" {
  description = "EKS managed node group instance types"
  type        = list(string)
}

# EKS API Server public endpoint 활성화 여부입니다.
variable "eks_endpoint_public_access" {
  description = "Enable EKS public endpoint"
  type        = bool
}

# EKS API Server private endpoint 활성화 여부입니다.
variable "eks_endpoint_private_access" {
  description = "Enable EKS private endpoint"
  type        = bool
}

# EKS public endpoint에 접근 가능한 CIDR 목록입니다.
# dev는 팀원 IP/32만 허용하고, prod는 public access false를 권장합니다.
variable "eks_public_access_cidrs" {
  description = "Allowed CIDR blocks for EKS public endpoint"
  type        = list(string)
  default     = []
}

# EKS Control Plane Logging 설정입니다.
# audit 로그는 누가 kubectl로 어떤 작업을 했는지 추적하는 데 중요합니다.
variable "enabled_cluster_log_types" {
  description = "EKS control plane log types"
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}

# EKS Admin 권한을 줄 IAM User/Role ARN 목록입니다.
variable "admin_principal_arns" {
  description = "IAM principal ARNs for EKS admin access"
  type        = list(string)
  default     = []
}

# EKS Developer 권한을 줄 IAM User/Role ARN 목록입니다.
variable "developer_principal_arns" {
  description = "IAM principal ARNs for EKS developer access"
  type        = list(string)
  default     = []
}

# EKS Viewer 권한을 줄 IAM User/Role ARN 목록입니다.
variable "viewer_principal_arns" {
  description = "IAM principal ARNs for EKS viewer access"
  type        = list(string)
  default     = []
}

# RDS 인스턴스 타입입니다.
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

# RDS Multi-AZ 여부입니다. dev는 false, prod는 true를 권장합니다.
variable "db_multi_az" {
  description = "Enable RDS Multi-AZ"
  type        = bool
}

# RDS 삭제 방지 여부입니다. dev는 false, prod는 true를 권장합니다.
variable "db_deletion_protection" {
  description = "Enable RDS deletion protection"
  type        = bool
}

# RDS 삭제 시 final snapshot 생략 여부입니다.
# dev는 true, prod는 false를 권장합니다.
variable "db_skip_final_snapshot" {
  description = "Skip final snapshot when deleting RDS"
  type        = bool
}

# RDS 백업 보관 기간입니다.
variable "db_backup_retention" {
  description = "RDS backup retention days"
  type        = number
}

# Redis 노드 타입입니다.
variable "redis_node_type" {
  description = "ElastiCache Redis node type"
  type        = string
}

# Redis replica 수입니다. dev는 0, prod는 1 이상을 권장합니다.
variable "redis_replica_count" {
  description = "Redis replica count"
  type        = number
}

# Redis Multi-AZ 여부입니다.
variable "redis_multi_az_enabled" {
  description = "Enable Redis Multi-AZ"
  type        = bool
}

# Redis 자동 failover 여부입니다.
variable "redis_automatic_failover" {
  description = "Enable Redis automatic failover"
  type        = bool
}

# Bastion 생성 여부입니다.
variable "bastion_enabled" {
  description = "Enable bastion EC2"
  type        = bool
  default     = true
}

# SSH 접근 허용 CIDR입니다.
# SSM만 사용할 예정이므로 기본값은 빈 배열입니다.
variable "bastion_ssh_cidr_blocks" {
  description = "Allowed SSH CIDRs. Keep empty when using SSM only."
  type        = list(string)
  default     = []
}

# 이미지 업로드용 S3 버킷 생성 여부입니다.
variable "image_bucket_enabled" {
  description = "Enable S3 image bucket"
  type        = bool
  default     = true
}

# React 정적 파일 배포용 S3 버킷 생성 여부입니다.
variable "frontend_bucket_enabled" {
  description = "Enable S3 frontend bucket"
  type        = bool
  default     = false
}

# Frontend S3 앞단에 CloudFront를 둘지 여부입니다.
variable "cloudfront_enabled" {
  description = "Enable CloudFront for frontend bucket"
  type        = bool
  default     = false
}

# CloudWatch Log 보관 기간입니다.
variable "log_retention_days" {
  description = "CloudWatch log retention days"
  type        = number
  default     = 7
}

# 생성할 ECR Repository 이름 목록입니다.
# name_prefix와 조합되어 실제 Repository 이름이 결정됩니다.
# 예:
# ecr_repositories = ["backend", "frontend"]
# → team6-nowait-dev-backend
# → team6-nowait-dev-frontend
variable "ecr_repositories" {
  description = "List of ECR repository names to create"
  type        = list(string)
}

# 이미지 태그 변경 가능 여부입니다.
# dev:  MUTABLE  (latest 태그 재사용 가능)
# prod: IMMUTABLE (이미지 덮어쓰기 방지)
variable "ecr_image_tag_mutability" {
  description = "Image tag mutability setting (MUTABLE | IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

# 이미지 push 시 자동 취약점 스캔 여부입니다.
variable "ecr_scan_on_push" {
  description = "Enable image vulnerability scan on push"
  type        = bool
  default     = true
}

# Lifecycle Policy 활성화 여부입니다.
# 오래된 이미지를 자동 정리하여 ECR 스토리지 비용을 절감합니다.
variable "ecr_lifecycle_policy_enabled" {
  description = "Enable ECR lifecycle policy"
  type        = bool
  default     = true
}

# 보관할 최대 이미지 수입니다.
# 이 수를 초과하면 오래된 이미지부터 자동 삭제됩니다.
# dev:  30 (기본값)
# prod: 50~100 권장
variable "ecr_max_image_count" {
  description = "Maximum number of images to keep per repository"
  type        = number
  default     = 30
}

# 태그 없는 이미지 보관 기간입니다 (일 단위).
# 이 기간이 지난 untagged 이미지는 자동으로 삭제됩니다.
variable "ecr_untagged_image_days" {
  description = "Days to retain untagged images before deletion"
  type        = number
  default     = 7
}
