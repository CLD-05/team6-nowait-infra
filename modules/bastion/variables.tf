variable "project" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  description = "Bastion을 배치할 public 서브넷 ID"
  type        = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}
