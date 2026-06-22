variable "root_domain" {
  description = "와일드카드 인증서 대상 도메인 (예: nowait.singleuser.cloud)"
  type        = string
}

variable "route53_zone_id" {
  description = "DNS 검증 레코드를 추가할 Route53 호스팅 영역 ID"
  type        = string
}
