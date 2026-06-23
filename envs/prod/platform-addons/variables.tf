variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "team" {
  description = "Team tag value"
  type        = string
  default     = "team6"
}

variable "project" {
  description = "Project tag value"
  type        = string
  default     = "nowait"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "name_prefix" {
  description = "Common resource name prefix"
  type        = string
}

variable "iam_role_permissions_boundary" {
  description = "Required permissions boundary for IAM roles"
  type        = string
  default     = "arn:aws:iam::194722398200:policy/TeamRuntimeBoundary"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

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

variable "addon_versions" {
  description = "Exact EKS add-on versions"
  type        = map(string)
  default     = {}
}

variable "enable_ebs_csi_pod_identity" {
  description = "Enable Pod Identity role for EBS CSI Driver"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "VPC ID for AWS Load Balancer Controller"
  type        = string
}

# AWS Load Balancer Controller Helm chart 버전
variable "lbc_chart_version" {
  description = "AWS Load Balancer Controller Helm chart version"
  type        = string
  default     = "1.13.0"
}

# metrics-server Helm chart 버전
variable "metrics_server_chart_version" {
  description = "metrics-server Helm chart version"
  type        = string
  default     = "3.12.2"
}

# External Secrets Operator Helm chart 버전
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

variable "external_secrets_secret_arns" {
  description = "Secrets Manager secret ARNs that ESO can read"
  type        = list(string)
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
  default     = "nowait-prod"
}

variable "nowait_api_service_account" {
  description = "Kubernetes ServiceAccount name for NoWait API"
  type        = string
  default     = "nowait-api-sa"
}

variable "image_bucket_arn" {
  description = "S3 image bucket ARN for NoWait API"
  type        = string
  default     = null
}

# ========================================
# KEDA / Karpenter / Monitoring
# ========================================
variable "enable_keda" {
  description = "Enable KEDA"
  type        = bool
  default     = true
}

variable "keda_chart_version" {
  description = "KEDA Helm chart version"
  type        = string
}

variable "keda_values_file" {
  description = "Path to KEDA values file"
  type        = string
  default     = null
}

variable "enable_karpenter" {
  description = "Enable Karpenter"
  type        = bool
  default     = true
}

variable "karpenter_chart_version" {
  description = "Karpenter Helm chart version"
  type        = string
}

variable "karpenter_values_file" {
  description = "Path to Karpenter values file"
  type        = string
  default     = null
}

variable "enable_kube_prometheus_stack" {
  description = "Enable kube-prometheus-stack"
  type        = bool
  default     = true
}

variable "kube_prometheus_stack_chart_version" {
  description = "kube-prometheus-stack Helm chart version"
  type        = string
}

variable "kube_prometheus_stack_values_file" {
  description = "Path to kube-prometheus-stack values file"
  type        = string
  default     = null
}

# ========================================
# Argo CD
# ========================================
variable "enable_argocd" {
  description = "Enable Argo CD"
  type        = bool
  default     = true
}

variable "argocd_chart_version" {
  description = "Argo CD Helm chart version"
  type        = string
}

variable "argocd_values_file" {
  description = "Path to Argo CD values file"
  type        = string
  default     = null
}