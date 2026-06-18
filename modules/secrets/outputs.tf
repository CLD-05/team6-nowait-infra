output "secret_prefix" {
  description = "Secrets Manager secret prefix for this environment"
  value       = var.secret_prefix
}

output "secret_names" {
  description = "Secrets Manager secret names"
  value = {
    for key, secret in aws_secretsmanager_secret.this :
    key => secret.name
  }
}

output "secret_arns" {
  description = "Secrets Manager secret ARNs"
  value = {
    for key, secret in aws_secretsmanager_secret.this :
    key => secret.arn
  }
}