# 리소스 이름 앞에 붙일 공통 prefix입니다.
# 예:
# dev  = team6-nowait-dev
# prod = team6-nowait-prod
variable "name_prefix" {
  description = "Common resource name prefix"
  type        = string
}

# 생성할 ECR Repository 이름 목록입니다.
# name_prefix와 조합되어 실제 Repository 이름이 결정됩니다.
#
# 예:
# repositories = ["backend", "frontend"]
# → team6-nowait-dev-backend
# → team6-nowait-dev-frontend
variable "repositories" {
  description = "List of ECR repository names to create"
  type        = list(string)
}

# 이미지 태그 변경 가능 여부입니다.
#
# MUTABLE:
# - 같은 태그로 덮어쓰기 가능
# - dev 환경에서 latest 태그 재사용 시 편리
#
# IMMUTABLE:
# - 한 번 push한 태그는 변경 불가
# - prod 환경 권장 (의도치 않은 이미지 덮어쓰기 방지)
variable "image_tag_mutability" {
  description = "Image tag mutability setting (MUTABLE | IMMUTABLE)"
  type        = string
  default     = "MUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability는 'MUTABLE' 또는 'IMMUTABLE'만 허용됩니다."
  }
}

# 이미지 push 시 자동 취약점 스캔 여부입니다.
#
# true:
# - push할 때마다 ECR이 자동으로 CVE 취약점 스캔
# - 보안 이슈 조기 발견 가능
#
# false:
# - 스캔 비활성화
# - 빠른 push가 필요한 경우에만 사용
variable "scan_on_push" {
  description = "Enable image vulnerability scan on push"
  type        = bool
  default     = true
}

# 이미지 암호화 방식입니다.
#
# AES256:
# - AWS 관리형 키로 암호화
# - 별도 비용 없음
# - dev/prod 모두 기본값으로 충분
#
# KMS:
# - 고객 관리형 KMS 키로 암호화
# - 키 로테이션 및 세밀한 접근 제어 가능
# - 추가 비용 발생
variable "encryption_type" {
  description = "Image encryption type (AES256 | KMS)"
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "encryption_type은 'AES256' 또는 'KMS'만 허용됩니다."
  }
}

# Lifecycle Policy 활성화 여부입니다.
#
# true:
# - 오래된 이미지를 자동으로 정리
# - ECR 스토리지 비용 절감
#
# false:
# - 이미지가 무한정 쌓임
# - 테스트 용도로만 비활성화 권장
variable "lifecycle_policy_enabled" {
  description = "Enable ECR lifecycle policy"
  type        = bool
  default     = true
}

# 보관할 최대 이미지 수입니다.
#
# 이 수를 초과하면 오래된 태그 이미지부터 자동 삭제됩니다.
#
# 예:
# max_image_count = 30
# → 31번째 이미지 push 시 가장 오래된 이미지 삭제
#
# dev:  30 (기본값)
# prod: 50~100 권장
variable "max_image_count" {
  description = "Maximum number of tagged images to keep"
  type        = number
  default     = 30
}

# 태그 없는 이미지 보관 기간입니다 (일 단위).
#
# CI/CD 파이프라인에서 태그 없이 push된 이미지는
# 이 기간이 지나면 자동으로 삭제됩니다.
#
# 예:
# untagged_image_days = 7
# → 7일 이상 된 untagged 이미지 자동 삭제
variable "untagged_image_days" {
  description = "Days to retain untagged images before deletion"
  type        = number
  default     = 7
}
