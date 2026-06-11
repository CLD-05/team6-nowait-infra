output "account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "github_oidc_provider_arn" {
  description = "GitHub OIDC Provider ARN"
  value       = module.github_oidc_provider.oidc_provider_arn
}