output "zone_id" {
  value = aws_route53_zone.this.zone_id
}

output "zone_name" {
  value = aws_route53_zone.this.name
}

output "name_servers" {
  description = "관리자에게 전달할 NS 4개"
  value       = aws_route53_zone.this.name_servers
}
