variable "name_prefix" {
  description = "Common resource name prefix"
  type        = string
}

variable "iam_role_permissions_boundary" {
  description = "Required permissions boundary for IAM roles"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for bastion instance"
  type        = string
}

variable "security_group_id" {
  description = "Bastion security group ID"
  type        = string
}

variable "instance_type" {
  description = "Bastion instance type"
  type        = string
  default     = "t3.micro"
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}