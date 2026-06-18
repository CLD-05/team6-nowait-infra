output "seoul_certificate_arn" {
  description = "ALB용 (ap-northeast-2)"
  value       = aws_acm_certificate_validation.seoul.certificate_arn
}

output "virginia_certificate_arn" {
  description = "CloudFront용 (us-east-1) — 트랙 4(CDN)에 전달"
  value       = aws_acm_certificate_validation.virginia.certificate_arn
}
