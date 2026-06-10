# 리소스 이름 앞에 붙일 공통 prefix입니다.
# 예:
# dev  = team6-nowait-dev
# prod = team6-nowait-prod
variable "name_prefix" {
  description = "Common resource name prefix"
  type        = string
}

# IAM Role 생성 시 반드시 붙여야 하는 permissions boundary입니다.
# 정책상 학생이 만드는 IAM Role에는 필수입니다.
variable "iam_role_permissions_boundary" {
  description = "Required permissions boundary for IAM roles"
  type        = string
}

# EKS가 배치될 VPC ID입니다.
# network 모듈의 output인 module.network.vpc_id를 넘겨받습니다.
variable "vpc_id" {
  description = "VPC ID for EKS"
  type        = string
}

# EKS Cluster와 Node Group이 사용할 Private App Subnet 목록입니다.
# EKS Node는 외부에 직접 노출되면 안 되므로 private app subnet에 배치합니다.
variable "private_app_subnet_ids" {
  description = "Private app subnet IDs for EKS"
  type        = list(string)
}

# EKS Kubernetes 버전입니다.
# 우리는 1.34로 고정합니다.
variable "cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.34"
}

# EKS API Server public endpoint 활성화 여부입니다.
#
# dev:
# - true 가능
# - 단, 팀원 IP/32만 허용
#
# prod:
# - false 권장
variable "endpoint_public_access" {
  description = "Enable EKS public endpoint"
  type        = bool
}

# EKS API Server private endpoint 활성화 여부입니다.
#
# dev/prod 모두 true 권장입니다.
variable "endpoint_private_access" {
  description = "Enable EKS private endpoint"
  type        = bool
}

# EKS public endpoint에 접근 가능한 CIDR 목록입니다.
#
# dev:
# - 팀원 공인 IP/32만 입력
#
# prod:
# - public endpoint false면 빈 배열 사용
variable "public_access_cidrs" {
  description = "Allowed CIDRs for EKS public endpoint"
  type        = list(string)
  default     = []
}

# EKS Control Plane 로그입니다.
#
# api:
# - Kubernetes API 요청 로그
#
# audit:
# - 누가 어떤 작업을 했는지 추적하는 감사 로그
#
# authenticator:
# - IAM 인증 관련 로그
#
# controllerManager, scheduler:
# - 클러스터 내부 제어 로그
variable "enabled_cluster_log_types" {
  description = "EKS control plane log types"
  type        = list(string)
  default = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
}

# CloudWatch Log 보관 기간입니다.
variable "log_retention_days" {
  description = "CloudWatch log retention days"
  type        = number
  default     = 7
}

# EKS Node Group의 desired size입니다.
# 실제로 유지하고 싶은 노드 개수입니다.
variable "node_desired_size" {
  description = "EKS managed node group desired size"
  type        = number
}

# EKS Node Group의 최소 노드 개수입니다.
variable "node_min_size" {
  description = "EKS managed node group min size"
  type        = number
}

# EKS Node Group의 최대 노드 개수입니다.
variable "node_max_size" {
  description = "EKS managed node group max size"
  type        = number
}

# EKS Worker Node EC2 인스턴스 타입입니다.
#
# dev:
# - t3.medium
#
# prod:
# - t3.large 권장
variable "node_instance_types" {
  description = "EKS managed node group instance types"
  type        = list(string)
}

# Worker Node 루트 디스크 크기입니다.
variable "node_disk_size" {
  description = "EKS node disk size in GiB"
  type        = number
  default     = 20
}

# EKS Admin 권한을 줄 IAM User/Role ARN 목록입니다.
#
# 예:
# arn:aws:iam::194722398200:user/your-name
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