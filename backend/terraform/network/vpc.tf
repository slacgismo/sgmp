module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.resource_prefix}_vpc"
  cidr = var.cidr

  azs             = var.availability_zones
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  tags = var.tags
}