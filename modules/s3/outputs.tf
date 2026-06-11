output "image_bucket_id" {
  description = "Image S3 bucket ID"
  value       = var.image_bucket_enabled ? aws_s3_bucket.image[0].id : null
}

output "image_bucket_arn" {
  description = "Image S3 bucket ARN"
  value       = var.image_bucket_enabled ? aws_s3_bucket.image[0].arn : null
}

output "image_bucket_domain_name" {
  description = "Image S3 bucket regional domain name"
  value       = var.image_bucket_enabled ? aws_s3_bucket.image[0].bucket_regional_domain_name : null
}

output "frontend_bucket_id" {
  description = "Frontend S3 bucket ID"
  value       = var.frontend_bucket_enabled ? aws_s3_bucket.frontend[0].id : null
}

output "frontend_bucket_arn" {
  description = "Frontend S3 bucket ARN"
  value       = var.frontend_bucket_enabled ? aws_s3_bucket.frontend[0].arn : null
}

output "frontend_bucket_domain_name" {
  description = "Frontend S3 bucket regional domain name"
  value       = var.frontend_bucket_enabled ? aws_s3_bucket.frontend[0].bucket_regional_domain_name : null
}