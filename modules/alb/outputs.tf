output "alb_arn" {
  value = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "Route53 alias 레코드의 target"
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "Route53 alias 레코드의 zone_id"
  value       = aws_lb.this.zone_id
}

output "https_listener_arn" {
  value = aws_lb_listener.https.arn
}

output "security_group_id" {
  description = "EKS 노드 SG에서 인바운드 허용 대상"
  value       = aws_security_group.alb.id
}
