variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "role_name_suffix" {
  description = "Role name suffix such as dev or prod"
  type        = string
}

variable "github_org" {
  description = "GitHub organization or user name"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "allowed_branches" {
  description = "Branches allowed to assume this role"
  type        = list(string)
}

variable "github_oidc_provider_arn" {
  description = "Existing GitHub OIDC Provider ARN"
  type        = string
}

variable "ecr_repository_arn" {
  description = "ECR repository ARN"
  type        = string
}

variable "ecr_access" {
  description = "ECR access level. push or read"
  type        = string

  validation {
    condition     = contains(["push", "read"], var.ecr_access)
    error_message = "ecr_access must be either push or read."
  }
}

variable "iam_role_permissions_boundary" {
  description = "Permissions boundary ARN for IAM role"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}