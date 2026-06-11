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

# Image Bucket 생성 여부
variable "image_bucket_enabled" {
  description = "Enable image upload S3 bucket"
  type        = bool
  default     = true
}

# Frontend Bucket 생성 여부
variable "frontend_bucket_enabled" {
  description = "Enable frontend static hosting S3 bucket"
  type        = bool
  default     = false
}

# Image Bucket CORS 허용 Origin
#
# dev: ["*"] 또는 로컬 주소
# prod: 실제 도메인으로 제한
variable "cors_allowed_origins" {
  description = "Allowed origins for image bucket CORS"
  type        = list(string)
  default     = ["*"]
}

# CloudFront Distribution ARN
#
# frontend bucket policy에서 OAC 조건으로 사용합니다.
# cloudfront 모듈에서 생성 후 넘겨받습니다.
# frontend_bucket_enabled = false이면 null로 두면 됩니다.
variable "cloudfront_distribution_arn" {
  description = "CloudFront distribution ARN for frontend bucket OAC policy"
  type        = string
  default     = null
}