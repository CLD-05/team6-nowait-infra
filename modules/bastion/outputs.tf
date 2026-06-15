output "instance_id" {
  description = "Bastion EC2 instance ID"
  value       = aws_instance.this.id
}

output "role_arn" {
  description = "Bastion IAM Role ARN"
  value       = aws_iam_role.this.arn
}

output "security_group_id" {
  description = "Bastion security group ID"
  value       = var.security_group_id
}