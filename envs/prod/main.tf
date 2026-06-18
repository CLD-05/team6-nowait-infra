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
    aws            = aws
    aws.us_east_1  = aws.us_east_1
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

  project   = var.project
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_ids[0]
}

module "eks" {
  source = "../../modules/eks"

  cluster_name       = var.eks_cluster_name
  cluster_version    = var.eks_cluster_version
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  node_instance_types = var.eks_node_instance_types
  node_desired_size  = var.eks_node_desired_size
  node_min_size      = var.eks_node_min_size
  node_max_size      = var.eks_node_max_size
}
