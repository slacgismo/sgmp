resource "aws_security_group" "lambda" {
  name        = "${var.resource_prefix}_lambda"
  description = "For Lambda traffic"
  vpc_id      = module.vpc.vpc_id

  ingress = []

  egress = [
    {
      description      = "for all outgoing traffics"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]

  tags = var.tags
}