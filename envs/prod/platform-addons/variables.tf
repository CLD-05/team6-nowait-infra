# AWS 리전
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

# 프로젝트 이름
variable "project" {
  description = "Project tag value"
  type        = string
  default     = "nowait"
}

# 환경 이름
variable "environment" {
  description = "Environment name"
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be dev or prod."
  }
}

# 리소스 이름 prefix
variable "name_prefix" {
  description = "Common resource name prefix. Must start with team6-."
  type        = string

  validation {
    condition     = startswith(var.name_prefix, "team6-")
    error_message = "name_prefix must start with team6-."
  }
}

# Pod Identity Role, Add-on Role 생성 시 필수 permissions boundary
variable "iam_role_permissions_boundary" {
  description = "Required permissions boundary for IAM roles created by students."
  type        = string
  default     = "arn:aws:iam::194722398200:policy/TeamRuntimeBoundary"
}

# Add-ons를 설치할 대상 EKS Cluster 이름
variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

# AWS Load Balancer Controller 설치 여부
variable "enable_aws_load_balancer_controller" {
  description = "Enable AWS Load Balancer Controller"
  type        = bool
  default     = true
}

# ArgoCD 설치 여부
variable "enable_argocd" {
  description = "Enable ArgoCD"
  type        = bool
  default     = true
}

# metrics-server 설치 여부
variable "enable_metrics_server" {
  description = "Enable metrics-server"
  type        = bool
  default     = true
}

# External Secrets Operator 설치 여부
variable "enable_external_secrets" {
  description = "Enable External Secrets Operator"
  type        = bool
  default     = true
}

# kube-prometheus-stack 설치 여부
# 애플리케이션 배포 이후 2차 단계에서 true로 변경합니다.
variable "enable_kube_prometheus_stack" {
  description = "Enable kube-prometheus-stack. Usually false until app is deployed."
  type        = bool
  default     = false
}
