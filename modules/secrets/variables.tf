variable "team" {
  description = "Team tag value"
  type        = string
}

variable "project" {
  description = "Project tag value"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "name_prefix" {
  description = "Common resource name prefix"
  type        = string
}

variable "rds_host" {
  description = "RDS host address"
  type        = string
}

variable "rds_port" {
  description = "RDS port"
  type        = string
}

variable "rds_database" {
  description = "RDS database name"
  type        = string
}

variable "rds_username" {
  description = "RDS username"
  type        = string
}

variable "rds_password" {
  description = "RDS password"
  type        = string
  sensitive   = true
}

variable "redis_host" {
  description = "Redis primary endpoint"
  type        = string
}

variable "redis_port" {
  description = "Redis port"
  type        = string
}

variable "jwt_secret" {
  description = "JWT secret for application"
  type        = string
  sensitive   = true
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

# ========================================
# AWS / S3 Application Config
# ========================================

variable "aws_region" {
  description = "AWS region for application"
  type        = string
}

variable "s3_image_bucket" {
  description = "S3 image bucket name for image upload"
  type        = string
}

variable "s3_image_prefix" {
  description = "S3 object key prefix for image upload"
  type        = string
}

# ========================================
# Application CORS Config
# ========================================

variable "app_allowed_origins" {
  description = "Allowed origins for backend application CORS"
  type        = list(string)
}