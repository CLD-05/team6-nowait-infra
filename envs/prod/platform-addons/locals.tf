locals {
  # platform-addons에서 생성되는 리소스에도 공통 태그를 적용합니다.
  default_tags = {
    Team        = var.team
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  # addons 모듈에 넘길 공통 정보입니다.
  common_context = {
    team         = var.team
    project      = var.project
    environment  = var.environment
    name_prefix  = var.name_prefix
    region       = var.region
    cluster_name = var.cluster_name
  }
}
