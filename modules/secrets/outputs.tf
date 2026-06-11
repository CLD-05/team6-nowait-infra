output "parameter_prefix" {
  description = "SSM Parameter Store prefix for this environment"
  value       = local.parameter_prefix
}

output "parameter_names" {
  description = "Created SSM parameter names"
  value       = [for parameter in aws_ssm_parameter.app : parameter.name]
}

output "rds_password_parameter_name" {
  description = "RDS password parameter name"
  value       = aws_ssm_parameter.app["/rds/password"].name
}

output "jwt_secret_parameter_name" {
  description = "JWT secret parameter name"
  value       = aws_ssm_parameter.app["/jwt/secret"].name
}