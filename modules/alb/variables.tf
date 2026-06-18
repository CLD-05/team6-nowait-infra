variable "project" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  description = "ALB가 걸쳐질 public 서브넷 (AZ 2개 이상)"
  type        = list(string)
}

variable "certificate_arn" {
  description = "서울 리전 ACM 인증서 ARN"
  type        = string
}
