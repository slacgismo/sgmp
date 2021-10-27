module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.resource_prefix}_vpc"
  cidr = "172.20.0.0/16"

  azs             = ["${var.region}a", "${var.region}b"]
  public_subnets  = ["172.20.0.0/20", "172.20.16.0/20"]
  private_subnets = ["172.20.32.0/20", "172.20.48.0/20"]

  tags = var.tags
}