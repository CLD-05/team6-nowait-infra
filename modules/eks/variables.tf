# ----------------------------------------
# 공통
# ----------------------------------------
variable "name_prefix" {
  description = "리소스 이름 앞에 붙는 prefix (예: team6-nowait-dev)"
  type        = string
}

# ----------------------------------------
# Network (modules/network output 참조)
# ----------------------------------------
variable "vpc_id" {
  description = "EKS 클러스터가 위치할 VPC ID"
  type        = string
}

variable "private_app_subnet_ids" {
  description = "EKS Node Group이 위치할 Private App Subnet ID 목록"
  type        = list(string)
}

# ----------------------------------------
# EKS Cluster
# ----------------------------------------
variable "cluster_version" {
  description = "EKS Kubernetes 버전"
  type        = string
  default     = "1.32"
}

variable "eks_endpoint_public_access" {
  description = "EKS API Server Public 접근 허용 여부 (dev: true / prod: false)"
  type        = bool
  default     = false
}

variable "eks_endpoint_private_access" {
  description = "EKS API Server Private 접근 허용 여부"
  type        = bool
  default     = true
}

variable "eks_public_access_cidrs" {
  description = "EKS Public endpoint 접근 허용 CIDR 목록 (팀원 IP/32)"
  type        = list(string)
  default     = []
}

variable "enabled_cluster_log_types" {
  description = "EKS Control Plane 로그 활성화 목록"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

# ----------------------------------------
# EKS Node Group
# ----------------------------------------
variable "node_instance_types" {
  description = "EKS Node EC2 인스턴스 타입"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "EKS Node Group 희망 노드 수"
  type        = number
  default     = 1
}

variable "node_min_size" {
  description = "EKS Node Group 최소 노드 수"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "EKS Node Group 최대 노드 수"
  type        = number
  default     = 3
}

# ----------------------------------------
# EKS Access Entry (팀원 IAM User ARN)
# ----------------------------------------
variable "admin_principal_arns" {
  description = "EKS Admin 권한을 부여할 IAM User ARN 목록"
  type        = list(string)
  default     = []
}

variable "developer_principal_arns" {
  description = "EKS Developer 권한을 부여할 IAM User ARN 목록"
  type        = list(string)
  default     = []
}

variable "viewer_principal_arns" {
  description = "EKS Viewer 권한을 부여할 IAM User ARN 목록"
  type        = list(string)
  default     = []
}

variable "iam_role_permissions_boundary" {
  description = "IAM Role 생성 시 필수로 붙여야 하는 permissions boundary ARN"
  type        = string
}
