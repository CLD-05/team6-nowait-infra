output "account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "github_oidc_provider_arn" {
  description = "GitHub OIDC Provider ARN"
  value       = module.github_oidc_provider.oidc_provider_arn
}

output "github_actions_dev_role_name" {
  description = "GitHub Actions IAM Role name for dev"
  value       = module.github_oidc_role_dev.role_name
}

output "github_actions_dev_role_arn" {
  description = "GitHub Actions IAM Role ARN for dev"
  value       = module.github_oidc_role_dev.role_arn
}

output "github_actions_prod_role_name" {
  description = "GitHub Actions IAM Role name for prod"
  value       = module.github_oidc_role_prod.role_name
}

output "github_actions_prod_role_arn" {
  description = "GitHub Actions IAM Role ARN for prod"
  value       = module.github_oidc_role_prod.role_arn
}