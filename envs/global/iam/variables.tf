# ========================================
# Common
# ========================================

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
  default     = "global"
}

variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
  default     = "team6-nowait"
}

# ========================================
# GitHub Actions OIDC Roles
# ========================================

variable "github_org" {
  description = "GitHub organization or user name"
  type        = string
  default     = "CLD-05"
}

variable "github_repo" {
  description = "GitHub repository name for application repository"
  type        = string
  default     = "team6-nowait-app"
}

variable "ecr_repository_arn" {
  description = "Shared ECR repository ARN"
  type        = string
}

variable "iam_role_permissions_boundary" {
  description = "Required permissions boundary for IAM roles created by students"
  type        = string
  default     = "arn:aws:iam::194722398200:policy/TeamRuntimeBoundary"
}