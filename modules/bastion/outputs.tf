output "instance_id" {
  description = "SSM 접속용: aws ssm start-session --target <id>"
  value       = aws_instance.this.id
}

output "role_arn" {
  description = "Bastion IAM Role ARN"
  value       = aws_iam_role.this.arn
}

output "security_group_id" {
  description = "RDS/Redis SG에서 이 SG를 허용하면 Bastion에서 접근 가능"
  value       = var.security_group_id
}