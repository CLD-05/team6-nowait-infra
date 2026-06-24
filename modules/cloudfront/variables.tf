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
  default     = true
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

# [트랙 1] 연동용: us-east-1 ACM 인증서 ARN 변수 추가
variable "acm_virginia_certificate_arn" {
  description = "ACM Certificate ARN from us-east-1 (Track 1 output)"
  type        = string
  default     = null
}

# [트랙 1] 연동용: Route53 Hosted Zone ID 변수 추가
variable "route53_zone_id" {
  description = "Route53 Hosted Zone ID for domain A record alias"
  type        = string
  default     = null
}

variable "backend_domain_name" {
  type        = string
  description = "팀원이 고도화한 백엔드 서브도메인 주소 (api.nowait.singleuser.cloud)"
  default     = "api.nowait.singleuser.cloud" # 💡 디폴트값을 주면 상위 배포가 편해집니다!
}
