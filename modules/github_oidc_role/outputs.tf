output "role_name" {
  description = "GitHub Actions IAM Role name"
  value       = aws_iam_role.this.name
}

output "role_arn" {
  description = "GitHub Actions IAM Role ARN"
  value       = aws_iam_role.this.arn
}

output "ecr_policy_arn" {
  description = "ECR IAM Policy ARN"
  value       = aws_iam_policy.ecr.arn
}