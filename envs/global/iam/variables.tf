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