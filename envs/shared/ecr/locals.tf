data "aws_caller_identity" "current" {}

locals {
  default_tags = {
    Team        = var.team
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}