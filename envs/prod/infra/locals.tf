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