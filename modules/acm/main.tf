terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.us_east_1]
    }
  }
}

resource "aws_acm_certificate" "seoul" {
  domain_name               = var.root_domain
  subject_alternative_names = ["*.${var.root_domain}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "virginia" {
  provider                  = aws.us_east_1
  domain_name               = var.root_domain
  subject_alternative_names = ["*.${var.root_domain}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  validation_records = {
    for dvo in aws_acm_certificate.seoul.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }
}

resource "aws_route53_record" "validation" {
  for_each = local.validation_records

  zone_id = var.route53_zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60

  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "seoul" {
  certificate_arn         = aws_acm_certificate.seoul.arn
  validation_record_fqdns = [for r in aws_route53_record.validation : r.fqdn]
}

resource "aws_acm_certificate_validation" "virginia" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.virginia.arn
  validation_record_fqdns = [for r in aws_route53_record.validation : r.fqdn]
}
