variable "name_prefix" {
  description = "Common resource name prefix. Example: team6-nowait-dev"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones to use. Example: [\"ap-northeast-2a\", \"ap-northeast-2c\"]"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks. ALB and NAT Gateway are placed here."
  type        = list(string)
}

variable "private_app_subnet_cidrs" {
  description = "Private app subnet CIDR blocks. EKS nodes and application pods are placed here."
  type        = list(string)
}

variable "private_db_subnet_cidrs" {
  description = "Private DB subnet CIDR blocks. RDS and Redis are placed here."
  type        = list(string)
}

variable "nat_gateway_mode" {
  description = "NAT Gateway mode: single, per_az, none"
  type        = string
  default     = "single"

  validation {
    condition     = contains(["single", "per_az", "none"], var.nat_gateway_mode)
    error_message = "nat_gateway_mode must be one of: single, per_az, none."
  }
}

variable "eks_cluster_name" {
  description = "EKS cluster name for Kubernetes subnet tags"
  type        = string
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in VPC"
  type        = bool
  default     = true
}