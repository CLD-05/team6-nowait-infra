module "vpc" {
  source = "../../modules/vpc"

  project               = var.project
  vpc_cidr              = var.vpc_cidr
  azs                   = var.azs
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  isolated_subnet_cidrs = var.isolated_subnet_cidrs
}

module "route53" {
  source = "../../modules/route53"

  root_domain = var.root_domain
}

module "acm" {
  source = "../../modules/acm"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  root_domain     = var.root_domain
  route53_zone_id = module.route53.zone_id
}

module "alb" {
  source = "../../modules/alb"

  project           = var.project
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  certificate_arn   = module.acm.seoul_certificate_arn
}

resource "aws_route53_record" "api" {
  zone_id = module.route53.zone_id
  name    = "${var.api_subdomain}.${var.root_domain}"
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}

module "bastion" {
  source = "../../modules/bastion"

  name_prefix                   = "${var.project}-prod"
  iam_role_permissions_boundary = var.iam_role_permissions_boundary
  subnet_id                     = module.vpc.public_subnet_ids[0]
  security_group_id             = aws_security_group.bastion.id
  eks_cluster_arn               = module.eks.cluster_arn
  instance_type                 = "t3.micro"
  common_tags                   = local.common_tags
}

module "eks" {
  source = "../../modules/eks"

  name_prefix                   = "${var.project}-prod"
  iam_role_permissions_boundary = var.iam_role_permissions_boundary
  vpc_id                        = module.vpc.vpc_id
  private_app_subnet_ids        = module.vpc.private_subnet_ids
  cluster_version               = var.eks_cluster_version
  endpoint_public_access        = false
  endpoint_private_access       = true
  public_access_cidrs           = []
  node_desired_size             = var.eks_node_desired_size
  node_min_size                 = var.eks_node_min_size
  node_max_size                 = var.eks_node_max_size
  node_instance_types           = var.eks_node_instance_types
  admin_principal_arns          = var.admin_principal_arns
  common_tags                   = local.common_tags
}

locals {
  common_tags = {
    Project     = var.project
    Environment = "prod"
    Team        = "team6"
    ManagedBy   = "terraform"
  }
}

resource "aws_security_group" "bastion" {
  name        = "${var.project}-prod-bastion-sg"
  description = "Bastion SG: SSM only, no inbound"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project}-prod-bastion-sg"
  })
}
