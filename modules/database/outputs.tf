# 스프링부트 application.yml에 들어갈 값들이에요

output "cluster_endpoint" {
  description = "쓰기 엔드포인트 (Writer) - 스프링부트 메인 DB URL"
  value       = aws_rds_cluster.this.endpoint
}

output "cluster_reader_endpoint" {
  description = "읽기 엔드포인트 (Reader) - 읽기 전용 쿼리용"
  value       = aws_rds_cluster.this.reader_endpoint
}

output "cluster_port" {
  description = "DB 포트"
  value       = aws_rds_cluster.this.port
}

output "db_name" {
  description = "데이터베이스 이름"
  value       = aws_rds_cluster.this.database_name
}

output "db_username" {
  description = "마스터 유저 이름"
  value       = aws_rds_cluster.this.master_username
}

output "secret_manager_arn" {
  description = "DB 비밀번호가 저장된 Secrets Manager ARN"
  value       = length(aws_rds_cluster.this.master_user_secret) > 0 ? aws_rds_cluster.this.master_user_secret[0].secret_arn : null
}

output "security_group_id" {
  description = "RDS 보안 그룹 ID (EKS 등에서 참조용)"
  value       = aws_security_group.rds.id
}
