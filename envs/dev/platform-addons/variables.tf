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