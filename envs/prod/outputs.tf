output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "isolated_subnet_ids" {
  description = "트랙 2(RDS/ElastiCache)에 전달할 격리 서브넷 ID"
  value       = module.vpc.isolated_subnet_ids
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_oidc_provider_arn" {
  description = "IRSA 설정 시 사용 (트랙 3에 전달)"
  value       = module.eks.oidc_provider_arn
}

output "bastion_instance_id" {
  description = "SSM 접속: aws ssm start-session --target <id>"
  value       = module.bastion.instance_id
}

output "bastion_security_group_id" {
  description = "트랙 2(RDS/Redis SG)에서 인바운드 허용 대상"
  value       = module.bastion.security_group_id
}

output "acm_virginia_certificate_arn" {
  description = "트랙 4(CloudFront)에 전달"
  value       = module.acm.virginia_certificate_arn
}

output "acm_seoul_certificate_arn" {
  value = module.acm.seoul_certificate_arn
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "alb_security_group_id" {
  description = "EKS 노드 SG에서 인바운드 허용 대상 (트랙 3에 전달)"
  value       = module.alb.security_group_id
}

output "api_url" {
  value = "https://${var.api_subdomain}.${var.root_domain}"
}

output "route53_zone_id" {
  description = "트랙 4(CDN)에 전달할 호스팅 영역 ID"
  value       = module.route53.zone_id
}

output "route53_name_servers" {
  description = "강성천님께 전달하여 singleuser.cloud 영역에 NS 레코드로 등록 요청"
  value       = module.route53.name_servers
}
