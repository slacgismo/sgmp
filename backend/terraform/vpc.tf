module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.resource_prefix}_vpc"
  cidr = "172.20.0.0/16"

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets  = ["172.20.1.0/24", "172.20.2.0/24", "172.20.3.0/24"]

  tags = local.tags
}