variable "name_prefix" {
  description = "Common resource name prefix"
  type        = string

  validation {
    condition     = startswith(var.name_prefix, "team6-")
    error_message = "name_prefix must start with team6-."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# CloudFront 생성 여부
# dev 초기: false
# prod: true
variable "cloudfront_enabled" {
  description = "Enable CloudFront distribution"
  type        = bool
  default     = false
}

# CloudFront Price Class
# PriceClass_100: 북미/유럽만 (저렴)
# PriceClass_200: 북미/유럽/아시아 (중간)
# PriceClass_All: 전체 (비쌈)
variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_200"
}

# S3 Frontend Bucket domain name
# modules/s3의 frontend_bucket_domain_name output을 넘겨받습니다.
variable "frontend_bucket_domain_name" {
  description = "Frontend S3 bucket regional domain name"
  type        = string
  default     = null
}

# ALB DNS name
# modules/eks 또는 ingress에서 생성된 ALB DNS를 넘겨받습니다.
variable "alb_dns_name" {
  description = "ALB DNS name for API requests"
  type        = string
  default     = null
}