locals {
  # Replication Group ID입니다.
  # ElastiCache 콘솔에서 식별자로 사용됩니다.
  replication_group_id = "${var.name_prefix}-redis"

  # Subnet Group 이름입니다.
  subnet_group_name = "${var.name_prefix}-redis-subnet-group"

  # Security Group 이름입니다.
  security_group_name = "${var.name_prefix}-redis-sg"
}
