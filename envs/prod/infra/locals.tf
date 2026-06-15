# 현재 리전에서 사용 가능한 AZ 목록을 조회합니다.
# ap-northeast-2a, ap-northeast-2c처럼 AZ 이름을 직접 하드코딩하지 않기 위함입니다.
data "aws_availability_zones" "available" {
  state = "available"
}

# 현재 AWS 계정 ID를 조회합니다.
# S3 버킷명, ARN 출력 등에 사용할 수 있습니다.
data "aws_caller_identity" "current" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  eks_cluster_name = "${var.name_prefix}-eks"

  default_tags = {
    Team        = var.team
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }

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