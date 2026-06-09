# ----------------------------------------
# AZ 조회 (하드코딩 X)
# ----------------------------------------
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs       = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  nat_count = var.nat_gateway_mode == "per_az" ? var.az_count : 1
}

# ----------------------------------------
# VPC
# ----------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

# ----------------------------------------
# Public Subnet
# ----------------------------------------
resource "aws_subnet" "public" {
  count = var.az_count

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                     = "${var.name_prefix}-public-${count.index + 1}"
    "kubernetes.io/role/elb" = "1"
  }
}

# ----------------------------------------
# Private App Subnet
# ----------------------------------------
resource "aws_subnet" "private_app" {
  count = var.az_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = {
    Name                              = "${var.name_prefix}-private-app-${count.index + 1}"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# ----------------------------------------
# Private DB Subnet
# ----------------------------------------
resource "aws_subnet" "private_db" {
  count = var.az_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_db_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = {
    Name = "${var.name_prefix}-private-db-${count.index + 1}"
  }
}

# ----------------------------------------
# Internet Gateway
# ----------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

# ----------------------------------------
# Elastic IP (NAT Gateway용)
# ----------------------------------------
resource "aws_eip" "nat" {
  count  = local.nat_count
  domain = "vpc"

  tags = {
    Name = "${var.name_prefix}-nat-eip-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.main]
}

# ----------------------------------------
# NAT Gateway
# ----------------------------------------
resource "aws_nat_gateway" "main" {
  count = local.nat_count

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.name_prefix}-nat-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.main]
}

# ----------------------------------------
# Public Route Table
# ----------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.name_prefix}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = var.az_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ----------------------------------------
# Private Route Table
# ----------------------------------------
resource "aws_route_table" "private" {
  count  = local.nat_count
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "${var.name_prefix}-private-rt-${count.index + 1}"
  }
}

# Private App Subnet 연결
resource "aws_route_table_association" "private_app" {
  count = var.az_count

  subnet_id = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private[
    var.nat_gateway_mode == "per_az" ? count.index : 0
  ].id
}

# Private DB Subnet 연결
resource "aws_route_table_association" "private_db" {
  count = var.az_count

  subnet_id = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private[
    var.nat_gateway_mode == "per_az" ? count.index : 0
  ].id
}
