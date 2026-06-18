variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "project" {
  type    = string
  default = "nowait"
}

variable "root_domain" {
  type    = string
  default = "nowait.singleuser.cloud"
}

variable "api_subdomain" {
  type    = string
  default = "api"
}

variable "vpc_cidr" {
  type    = string
  default = "10.6.128.0/17"
}

variable "azs" {
  type    = list(string)
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.6.128.0/24", "10.6.129.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.6.144.0/20", "10.6.160.0/20"]
}

variable "isolated_subnet_cidrs" {
  description = "RDS/ElastiCache용 격리 서브넷 (NAT/IGW 라우팅 없음)"
  type        = list(string)
  default     = ["10.6.176.0/24", "10.6.177.0/24"]
}

variable "eks_cluster_name" {
  type    = string
  default = "nowait-prod"
}

variable "eks_cluster_version" {
  type    = string
  default = "1.34"
}

variable "admin_principal_arns" {
  description = "EKS Admin 권한 부여 대상 IAM principal ARN 목록"
  type        = list(string)
  default     = []
}

variable "eks_node_instance_types" {
  type    = list(string)
  default = ["t3.large"]
}

variable "eks_node_desired_size" {
  type    = number
  default = 2
}

variable "eks_node_min_size" {
  type    = number
  default = 2
}

variable "eks_node_max_size" {
  type    = number
  default = 8
}
