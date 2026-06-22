provider "aws" {
  # AWS 리전은 ap-northeast-2를 기본으로 사용합니다.
  region = var.region

  # 모든 AWS 리소스에 공통 태그를 자동으로 붙입니다.
  # 학원 정책상 Team=team6 태그가 반드시 필요합니다.
  default_tags {
    tags = local.default_tags
  }
}

# CloudFront에 붙일 ACM 인증서는 반드시 us-east-1에서 발급해야 하므로 alias 추가.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = local.default_tags
  }
}
