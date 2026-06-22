locals {
  # NAT Gateway 개수를 계산합니다.
  #
  # dev:
  # nat_gateway_mode = "single"
  # → NAT Gateway 1개
  #
  # prod:
  # nat_gateway_mode = "per_az"
  # public subnet이 2개이므로
  # → NAT Gateway 2개
  #
  # none:
  # → NAT Gateway 0개
  nat_gateway_count = (
    var.nat_gateway_mode == "single" ? 1 :
    var.nat_gateway_mode == "per_az" ? length(var.public_subnet_cidrs) :
    0
  )

  # Private App Subnet용 Route Table 개수를 계산합니다.
  #
  # NAT Gateway가 있으면 Private App Subnet별로 Route Table을 둡니다.
  # 이렇게 해야 prod에서 AZ별 NAT Gateway를 정확히 연결할 수 있습니다.
  #
  # NAT Gateway가 없으면 Route Table 1개만 만들어도 됩니다.
  private_app_route_table_count = (
    var.nat_gateway_mode == "none" ? 1 : length(var.private_app_subnet_cidrs)
  )
}