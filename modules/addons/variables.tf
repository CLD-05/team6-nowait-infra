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
variable "environment" {
  description = "Environment name"
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be dev or prod."
  }
}

# 리소스 이름 prefix입니다.
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

# Add-ons를 설치할 EKS Cluster 이름입니다.
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

# LBC가 ALB를 생성할 VPC ID입니다.
variable "vpc_id" {
  description = "VPC ID for AWS Load Balancer Controller"
  type        = string
}

# Helm chart 버전 고정용 변수들입니다.
variable "lbc_chart_version" {
  description = "AWS Load Balancer Controller Helm chart version"
  type        = string
  default     = "1.13.0"
}

variable "metrics_server_chart_version" {
  description = "metrics-server Helm chart version"
  type        = string
  default     = "3.12.2"
}

variable "eso_chart_version" {
  description = "External Secrets Operator Helm chart version"
  type        = string
  default     = "0.14.4"
}

variable "enable_eso_pod_identity" {
  description = "Enable Pod Identity IAM Role for External Secrets Operator"
  type        = bool
  default     = true
}

variable "secrets_parameter_prefix" {
  description = "SSM Parameter Store prefix that ESO can read. Example: /team6/nowait/dev"
  type        = string
}

# ========================================
# NoWait API Pod Identity
# ========================================

variable "enable_nowait_api_pod_identity" {
  description = "Enable Pod Identity IAM Role for NoWait API"
  type        = bool
  default     = true
}

variable "nowait_api_namespace" {
  description = "Kubernetes namespace for NoWait API"
  type        = string
  default     = "nowait-dev"
}

variable "nowait_api_service_account" {
  description = "Kubernetes ServiceAccount name for NoWait API"
  type        = string
  default     = "nowait-api"
}

variable "image_bucket_arn" {
  description = "S3 image bucket ARN for NoWait API"
  type        = string
  default     = null
}