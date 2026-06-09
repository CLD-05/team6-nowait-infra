provider "aws" {
  # AWS 리전은 ap-northeast-2를 기본으로 사용합니다.
  region = var.region

  # 모든 AWS 리소스에 공통 태그를 자동으로 붙입니다.
  # 멋사 정책상 Team=team6 태그가 반드시 필요합니다.
  default_tags {
    tags = local.default_tags
  }
}
