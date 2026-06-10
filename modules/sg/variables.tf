# 리소스 이름 prefix입니다.
# 예: team6-nowait-dev
variable "name_prefix" {
  description = "Common resource name prefix. Must start with team6-."
  type        = string

  validation {
    condition     = startswith(var.name_prefix, "team6-")
    error_message = "name_prefix must start with team6-."
  }
}

# SG가 속할 VPC ID입니다.
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

# VPC CIDR 블록입니다.
# SG 내부 통신 규칙에 사용합니다.
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "bastion_enabled" {
  description = "Enable bastion security group. prod only."
  type        = bool
  default     = false
}
