# AWS 리전입니다.
variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

# 학원 정책상 Team 태그는 team6이어야 합니다.
variable "team" {
  description = "Team tag value"
  type        = string
  default     = "team6"

  validation {
    condition     = var.team == "team6"
    error_message = "team must be team6."
  }
}

# 프로젝트 이름입니다.
variable "project" {
  description = "Project tag value"
  type        = string
  default     = "nowait"
}

# 환경 이름입니다.
# 여기서는 prod로 사용합니다.
variable "environment" {
  description = "Environment name"
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be dev or prod."
  }
}

# 리소스 이름 prefix입니다.
# 예: team6-nowait-prod
variable "name_prefix" {
  description = "Common resource name prefix"
  type        = string

  validation {
    condition     = startswith(var.name_prefix, "team6-")
    error_message = "name_prefix must start with team6-."
  }
}

# IAM Role 생성 시 필수 permissions boundary입니다.
# EBS CSI Driver용 Pod Identity Role에 사용합니다.
variable "iam_role_permissions_boundary" {
  description = "Required permissions boundary for IAM roles"
  type        = string
  default     = "arn:aws:iam::194722398200:policy/TeamRuntimeBoundary"
}

# Add-ons를 설치할 prod EKS Cluster 이름입니다.
variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

# 설치할 EKS Add-on 목록입니다.
variable "eks_addons" {
  description = "EKS add-ons to install"
  type        = list(string)

  default = [
    "vpc-cni",
    "coredns",
    "kube-proxy",
    "eks-pod-identity-agent",
    "aws-ebs-csi-driver"
  ]
}

# Add-on 버전 고정용 map입니다.
# 처음에는 비워두면 AWS/EKS가 EKS 1.34에 맞는 기본 호환 버전을 선택합니다.
variable "addon_versions" {
  description = "Exact EKS add-on versions"
  type        = map(string)
  default     = {}
}

# EBS CSI Driver에 Pod Identity Role을 연결할지 여부입니다.
variable "enable_ebs_csi_pod_identity" {
  description = "Enable Pod Identity role for EBS CSI Driver"
  type        = bool
  default     = true
}