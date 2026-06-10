# ----------------------------------------
# VPC
# ----------------------------------------
output "vpc_id" {
  description = "생성된 VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "VPC CIDR 블록"
  value       = aws_vpc.main.cidr_block
}

# ----------------------------------------
# Subnet IDs
# ----------------------------------------
output "public_subnet_ids" {
  description = "Public Subnet ID 목록 (ALB, NAT Gateway 위치)"
  value       = aws_subnet.public[*].id
}

output "private_app_subnet_ids" {
  description = "Private App Subnet ID 목록 (EKS Node, API Pod, Worker Pod 위치)"
  value       = aws_subnet.private_app[*].id
}

output "private_db_subnet_ids" {
  description = "Private DB Subnet ID 목록 (RDS, Redis 위치)"
  value       = aws_subnet.private_db[*].id
}

# ----------------------------------------
# NAT Gateway
# ----------------------------------------
output "nat_gateway_ids" {
  description = "NAT Gateway ID 목록"
  value       = aws_nat_gateway.main[*].id
}

output "nat_public_ips" {
  description = "NAT Gateway에 할당된 EIP 목록"
  value       = aws_eip.nat[*].public_ip
}
