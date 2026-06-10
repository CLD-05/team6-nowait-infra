output "account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "repository_name" {
  description = "ECR repository name"
  value       = module.ecr.repository_name
}

output "repository_arn" {
  description = "ECR repository ARN"
  value       = module.ecr.repository_arn
}

output "repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}

output "registry_id" {
  description = "ECR registry ID"
  value       = module.ecr.registry_id
}