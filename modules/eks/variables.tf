variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  description = "EKS Control Plane ENI + Node Group이 들어갈 private 서브넷"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Control Plane public endpoint용 (현재는 사용 안 함)"
  type        = list(string)
  default     = []
}

variable "node_instance_types" {
  type = list(string)
}

variable "node_desired_size" {
  type = number
}

variable "node_min_size" {
  type = number
}

variable "node_max_size" {
  type = number
}
