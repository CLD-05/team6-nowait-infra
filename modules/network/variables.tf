variable "name_prefix" {
  description = "리소스 이름 앞에 붙는 prefix (예: team6-nowait-dev)"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
}

variable "az_count" {
  description = "사용할 AZ 개수 (AZ 이름 하드코딩 X)"
  type        = number
  default     = 2
}

variable "public_subnet_cidrs" {
  description = "Public Subnet CIDR 목록 (az_count 개수와 일치해야 함)"
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) >= var.az_count
    error_message = "public_subnet_cidrs 개수는 az_count 이상이어야 합니다."
  }
}

variable "private_app_subnet_cidrs" {
  description = "Private App Subnet CIDR 목록 (EKS Node / API Pod / Worker Pod 용)"
  type        = list(string)

  validation {
    condition     = length(var.private_app_subnet_cidrs) >= var.az_count
    error_message = "private_app_subnet_cidrs 개수는 az_count 이상이어야 합니다."
  }
}

variable "private_db_subnet_cidrs" {
  description = "Private DB Subnet CIDR 목록 (RDS / Redis 용)"
  type        = list(string)

  validation {
    condition     = length(var.private_db_subnet_cidrs) >= var.az_count
    error_message = "private_db_subnet_cidrs 개수는 az_count 이상이어야 합니다."
  }
}

variable "nat_gateway_mode" {
  description = "NAT Gateway 생성 방식 (single: 1개 / per_az: AZ별 1개)"
  type        = string
  default     = "single"

  validation {
    condition     = contains(["single", "per_az"], var.nat_gateway_mode)
    error_message = "nat_gateway_mode는 'single' 또는 'per_az'만 허용됩니다."
  }
}
