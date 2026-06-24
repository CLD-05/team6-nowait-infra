# ========================================
# CloudFront Origin Access Control (OAC)
#
# S3 Frontend Bucket에 대한 접근을 CloudFront만 허용합니다.
# 기존 OAI 방식보다 보안이 강화된 OAC 방식을 사용합니다.
# ========================================
resource "aws_cloudfront_origin_access_control" "frontend" {
  count = var.cloudfront_enabled ? 1 : 0

  name                              = "${var.name_prefix}-frontend-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ========================================
# CloudFront Distribution
#
# 구조: 서브도메인
# 사용자 → CloudFront → S3 Frontend Bucket (정적 파일)
# ========================================
resource "aws_cloudfront_distribution" "this" {
  count = var.cloudfront_enabled ? 1 : 0

  enabled             = true
  default_root_object = "index.html"
  price_class         = var.price_class

  aliases = var.acm_virginia_certificate_arn != null ? ["nowait.singleuser.cloud"] : []

  # ----------------------------------------
  # Origin: S3 Frontend Bucket 단독 연결
  # ----------------------------------------
  origin {
    domain_name              = var.frontend_bucket_domain_name
    origin_id                = "S3-${var.name_prefix}-frontend"
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend[0].id
  }

  # 🚀 [추가 코딩] Origin 2: 백엔드 ALB 연결 통로 개통
  origin {
    domain_name = var.backend_domain_name
    origin_id   = "ALB-${var.name_prefix}-backend"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "http-only" # EKS 내부 통신 규격에 맞춤
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_read_timeout      = 60 # 💡 SSE 연결 유지를 위한 읽기 타임아웃
      origin_keepalive_timeout = 60 # 💡 SSE 연결 유지를 위한 킵얼라이브 타임아웃
    }
  }

  # ----------------------------------------
  # Default Cache Behavior
  # S3 정적 파일 (React 빌드 결과물)
  # ----------------------------------------
  default_cache_behavior {
    target_origin_id       = "S3-${var.name_prefix}-frontend"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    # React SPA: 캐시 1일
    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000
  }

  # 🚀 [추가 코딩] Ordered Cache Behavior: 백엔드 API 및 SSE 전용 라우팅 규칙
  # /api/ 경로로 들어오는 모든 요청은 캐시를 완전히 끄고 버퍼링을 우회하여 ALB로 직송합니다.
  ordered_cache_behavior {
    path_pattern     = "/api/*"
    target_origin_id = "ALB-${var.name_prefix}-backend"

    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"

    # 🚨 SSE 웨이팅 세션을 위한 핵심 보안 및 버퍼링 차단 설정
    # Managed-CachingDisabled ID를 주입하여 CloudFront의 응답 버퍼링을 끕니다.
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    # Managed-AllViewerExceptHostHeader ID를 주입하여 인증 헤더와 쿠키를 ALB로 패스합니다.
    origin_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac"
  }

  # ----------------------------------------
  # React SPA 라우팅
  # 404/403 응답을 index.html로 리다이렉트
  # ----------------------------------------
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.acm_virginia_certificate_arn
    ssl_support_method             = var.acm_virginia_certificate_arn != null ? "sni-only" : null
    minimum_protocol_version       = var.acm_virginia_certificate_arn != null ? "TLSv1.2_2021" : null
    cloudfront_default_certificate = var.acm_virginia_certificate_arn == null ? true : false
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-cf"
  })
}

# ========================================
# Route53 DNS A 레코드 추가 (도메인 자동 연결)
# ========================================
resource "aws_route53_record" "frontend" {
  count = var.cloudfront_enabled && var.route53_zone_id != null && var.route53_zone_id != "" ? 1 : 0

  zone_id = var.route53_zone_id
  name    = "nowait.singleuser.cloud"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this[0].domain_name
    zone_id                = aws_cloudfront_distribution.this[0].hosted_zone_id
    evaluate_target_health = false
  }
}
