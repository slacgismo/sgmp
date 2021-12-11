data "aws_route53_zone" "this" {
  name         = var.zone_name
  private_zone = false
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name  = var.zone_name
  zone_id      = data.aws_route53_zone.this.zone_id

  subject_alternative_names = [
    "*.${var.zone_name}"
  ]

  wait_for_validation = true

  tags = merge({
    Name = var.zone_name
  }, var.tags)
}

output "acm_certificate_arn" {
  description = "The ARN of the certificate"
  value       = module.acm.acm_certificate_arn
}