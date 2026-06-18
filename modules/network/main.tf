# ========================================
# VPC
# ========================================
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

# ========================================
# Internet Gateway
# ========================================
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-igw"
  })
}

# ========================================
# Public Subnets
#
# 위치:
# - ALB
# - NAT Gateway
#
# Kubernetes 태그:
# - internet-facing ALB 생성을 위해 필요
# ========================================
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

   tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-public-${count.index + 1}"

    # AWS Load Balancer Controller가 internet-facing ALB용 Public Subnet을 찾을 때 사용
    "kubernetes.io/role/elb"                       = "1"
   # 해당 EKS Cluster에서 사용할 수 있는 subnet이라는 표시
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  })

}

# ========================================
# Private App Subnets
#
# 위치:
# - EKS Worker Node
# - API Pod
# - Reservation Worker Pod
#
# Kubernetes 태그:
# - internal ALB/NLB 또는 private subnet 자동 탐색 시 사용
# ========================================
resource "aws_subnet" "private_app" {
  count = length(var.private_app_subnet_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_app_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-private-app-${count.index + 1}"

      "kubernetes.io/role/internal-elb"               = "1"
      "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    },
    var.enable_karpenter_discovery_tags ? {
      "karpenter.sh/discovery" = var.eks_cluster_name
    } : {}
  )
}

# ========================================
# Private DB Subnets
#
# 위치:
# - RDS
# - Redis
#
# 주의:
# - Kubernetes용 태그를 붙이지 않는다.
# - DB 전용 subnet이므로 NAT Gateway로 나가는 기본 route를 만들지 않는다.
# ========================================
resource "aws_subnet" "private_db" {
  count = length(var.private_db_subnet_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_db_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-private-db-${count.index + 1}"
  })
}

# ========================================
# Public Route Table
# ========================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-public-rf"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ========================================
# NAT Gateway EIP
# ========================================
resource "aws_eip" "nat" {
  count = local.nat_gateway_count

  domain = "vpc"

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-nat-eip-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.this]
}

# ========================================
# NAT Gateway
#
# single:
# - 첫 번째 Public Subnet에 NAT Gateway 1개 생성
#
# per_az:
# - 각 Public Subnet에 NAT Gateway 생성
#
# none:
# - 생성하지 않음
# ========================================
resource "aws_nat_gateway" "this" {
  count = local.nat_gateway_count

  allocation_id = aws_eip.nat[count.index].id

  subnet_id = aws_subnet.public[
    var.nat_gateway_mode == "single" ? 0 : count.index
  ].id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-nat-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.this]
}

# ========================================
# Private App Route Tables
#
# App Subnet은 외부 패키지 다운로드, ECR Pull, AWS API 접근 등이 필요할 수 있어서
# NAT Gateway를 통해 outbound 통신을 허용한다.
# ========================================
resource "aws_route_table" "private_app" {
  count = local.private_app_route_table_count

  vpc_id = aws_vpc.this.id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-private-app-rt-${count.index + 1}"
  })
}

resource "aws_route" "private_app_nat" {
  count = var.nat_gateway_mode == "none" ? 0 : length(aws_route_table.private_app)

  route_table_id         = aws_route_table.private_app[count.index].id
  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = aws_nat_gateway.this[
    var.nat_gateway_mode == "single" ? 0 : count.index
  ].id
}

resource "aws_route_table_association" "private_app" {
  count = length(aws_subnet.private_app)

  subnet_id = aws_subnet.private_app[count.index].id

  route_table_id = aws_route_table.private_app[
    var.nat_gateway_mode == "none" ? 0 : count.index
  ].id
}

# ========================================
# Private DB Route Table
#
# DB Subnet은 NAT Gateway로 나가는 기본 route를 두지 않는다.
# VPC 내부 local route만 사용한다.
# ========================================
resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-private-db-rt"
  })
}

resource "aws_route_table_association" "private_db" {
  count = length(aws_subnet.private_db)

  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private_db.id
}