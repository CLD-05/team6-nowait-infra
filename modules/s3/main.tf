# ========================================
# Image Bucket
#
# 용도:
# - 음식점 이미지, 메뉴 이미지 등 업로드 파일 저장
# - API 서버에서 Presigned URL로 직접 업로드/조회
#
# dev: enabled
# prod: enabled
# ========================================
resource "aws_s3_bucket" "image" {
  count = var.image_bucket_enabled ? 1 : 0

  bucket = "${var.name_prefix}-image"

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-image"
  })
}

resource "aws_s3_bucket_versioning" "image" {
  count = var.image_bucket_enabled ? 1 : 0

  bucket = aws_s3_bucket.image[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "image" {
  count = var.image_bucket_enabled ? 1 : 0

  bucket = aws_s3_bucket.image[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CORS 설정
#
# API 서버에서 Presigned URL을 발급하면
# 브라우저가 S3에 직접 PUT/GET 요청을 보냅니다.
# 이를 허용하기 위해 CORS를 설정합니다.
resource "aws_s3_bucket_cors_configuration" "image" {
  count = var.image_bucket_enabled ? 1 : 0

  bucket = aws_s3_bucket.image[0].id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE"]
    allowed_origins = var.cors_allowed_origins
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# ========================================
# Frontend Bucket
#
# 용도:
# - React 빌드 결과물 정적 파일 호스팅
# - CloudFront OAC를 통해서만 접근 허용
#
# dev 초기: disabled (로컬 실행)
# prod: enabled
# ========================================
resource "aws_s3_bucket" "frontend" {
  count = var.frontend_bucket_enabled ? 1 : 0

  bucket = "${var.name_prefix}-frontend"

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-frontend"
  })
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  count = var.frontend_bucket_enabled ? 1 : 0

  bucket = aws_s3_bucket.frontend[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Frontend Bucket Policy
#
# CloudFront OAC만 접근 허용합니다.
# cloudfront_distribution_arn은 modules/cloudfront에서 넘겨받습니다.
resource "aws_s3_bucket_policy" "frontend" {
  count = var.frontend_bucket_enabled && var.cloudfront_distribution_arn != null ? 1 : 0

  bucket = aws_s3_bucket.frontend[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontOAC"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.frontend[0].arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = var.cloudfront_distribution_arn
          }
        }
      }
    ]
  })
}