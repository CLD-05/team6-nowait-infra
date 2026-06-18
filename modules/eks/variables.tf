variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  description = "Common resource name prefix"
  type        = string
}

variable "iam_role_permissions_boundary" {
  description = "Required permissions boundary for IAM roles"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for EKS"
  type        = string
}

variable "private_app_subnet_ids" {
  description = "Private app subnet IDs for EKS"
  type        = list(string)
}

variable "cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.34"
}

variable "endpoint_public_access" {
  description = "Enable EKS public endpoint"
  type        = bool
}

variable "endpoint_private_access" {
  description = "Enable EKS private endpoint"
  type        = bool
}

variable "public_access_cidrs" {
  description = "Allowed CIDRs for EKS public endpoint"
  type        = list(string)
  default     = []
}

variable "enabled_cluster_log_types" {
  description = "EKS control plane log types"
  type        = list(string)
  default = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
}

variable "log_retention_days" {
  description = "CloudWatch log retention days"
  type        = number
  default     = 7
}

variable "node_desired_size" {
  description = "EKS managed node group desired size"
  type        = number
}

variable "node_min_size" {
  description = "EKS managed node group min size"
  type        = number
}

variable "node_max_size" {
  description = "EKS managed node group max size"
  type        = number
}

variable "node_instance_types" {
  description = "EKS managed node group instance types"
  type        = list(string)
}

variable "node_disk_size" {
  description = "EKS node disk size in GiB"
  type        = number
  default     = 20
}

variable "admin_principal_arns" {
  description = "IAM principal ARNs for EKS admin access"
  type        = list(string)
  default     = []
}

variable "developer_principal_arns" {
  description = "IAM principal ARNs for EKS developer access"
  type        = list(string)
  default     = []
}

variable "viewer_principal_arns" {
  description = "IAM principal ARNs for EKS viewer access"
  type        = list(string)
  default     = []
}