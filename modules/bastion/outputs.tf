output "instance_id" {
  description = "SSM 접속용: aws ssm start-session --target <id>"
  value       = aws_instance.bastion.id
}

output "security_group_id" {
  description = "RDS/Redis SG에서 이 SG를 허용하면 Bastion에서 접근 가능"
  value       = aws_security_group.bastion.id
}

output "role_arn" {
  value = aws_iam_role.bastion.arn
}
