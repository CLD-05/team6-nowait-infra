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