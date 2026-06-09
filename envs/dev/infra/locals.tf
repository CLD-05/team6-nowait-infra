# 현재 리전에서 사용 가능한 AZ 목록을 조회합니다.
# ap-northeast-2a, ap-northeast-2c처럼 AZ 이름을 직접 하드코딩하지 않기 위함입니다.
data "aws_availability_zones" "available" {
  state = "available"
}

# 현재 AWS 계정 ID를 조회합니다.
# S3 버킷명, ARN 출력 등에 사용할 수 있습니다.
data "aws_caller_identity" "current" {}

locals {
  # 사용할 AZ 개수만큼 잘라서 사용합니다.
  # 예: az_count = 2이면 사용 가능한 AZ 중 앞의 2개 사용
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  # 모든 리소스에 자동으로 붙일 공통 태그입니다.
  # Team 태그는 학원 정책상 필수입니다.
  default_tags = {
    Team        = var.team
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  # 모듈에 공통으로 넘길 수 있는 값들을 모아둔 객체입니다.
  # 필수는 아니지만, 모듈 호출 시 가독성을 높이기 위해 둡니다.
  common_context = {
    team        = var.team
    project     = var.project
    environment = var.environment
    name_prefix = var.name_prefix
    region      = var.region
    account_id  = data.aws_caller_identity.current.account_id
    azs         = local.azs
  }
}
