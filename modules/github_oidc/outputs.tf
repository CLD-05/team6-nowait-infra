output "oidc_provider_arn" {
  description = "GitHub OIDC Provider ARN"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "github_actions_role_name" {
  description = "GitHub Actions IAM Role name"
  value       = aws_iam_role.github_actions.name
}

output "github_actions_role_arn" {
  description = "GitHub Actions IAM Role ARN"
  value       = aws_iam_role.github_actions.arn
}

output "ecr_push_policy_arn" {
  description = "ECR push IAM policy ARN"
  value       = aws_iam_policy.ecr_push.arn
}