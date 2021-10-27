resource "aws_security_group" "lambda" {
  name        = "${var.resource_prefix}_lambda"
  description = "For Lambda traffic"
  vpc_id      = module.vpc.vpc_id

  ingress = []

  egress {
    description      = "All outgoing traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags
}

resource "aws_security_group" "tsdb" {
  name        = "${var.resource_prefix}_tsdb"
  description = "For TimescaleDB traffic"
  vpc_id      = module.vpc.vpc_id

  tags = var.tags
}

resource "aws_security_group_rule" "tsdb_allow_postgresql_inbound" {
  for_each = toset([aws_security_group.lambda.id, aws_security_group.web.id, aws_security_group.bastion.id])
  type        = "ingress"
  description = "Allow incoming PostgreSQL traffic"
  from_port = 5432
  to_port = 5432
  protocol = "tcp"
  source_security_group_id = each.key
  security_group_id = aws_security_group.tsdb.id
}

resource "aws_security_group_rule" "tsdb_allow_self_inbound" {
  type        = "ingress"
  description = "Allow replication PostgreSQL traffic"
  from_port = 5432
  to_port = 5432
  protocol = "tcp"
  self = true
  security_group_id = aws_security_group.tsdb.id
}

resource "aws_security_group_rule" "tsdb_allow_ssh_inbound" {
  description = "Allow incoming SSH traffic from Bastion"
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id = aws_security_group.tsdb.id
}

resource "aws_security_group_rule" "tsdb_allow_all_outbound" {
  description = "All outgoing traffic"
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.tsdb.id
}

module "tsdb_consul_security_group_rules" {
  source = "git::git@github.com:hashicorp/terraform-aws-consul.git//modules/consul-client-security-group-rules?ref=v0.11.0"
  security_group_id = aws_security_group.tsdb.id
  allowed_inbound_cidr_blocks = [var.cidr]
}

resource "aws_security_group" "web" {
  name        = "${var.resource_prefix}_web"
  description = "For API Server traffic"
  vpc_id      = module.vpc.vpc_id

  tags = var.tags
}

resource "aws_security_group_rule" "web_allow_http_inbound" {
  description = "Allow all incoming HTTP traffic"
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "web_allow_https_inbound" {
  description = "Allow all incoming HTTPS traffic"
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "web_allow_ssh_inbound" {
  description = "Allow incoming SSH traffic from Bastion"
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "web_allow_all_outbound" {
  description = "All outgoing traffic"
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.web.id
}

module "web_consul_security_group_rules" {
  source = "git::git@github.com:hashicorp/terraform-aws-consul.git//modules/consul-client-security-group-rules?ref=v0.11.0"
  security_group_id = aws_security_group.web.id
  allowed_inbound_cidr_blocks = [var.cidr]
}

resource "aws_security_group" "rds" {
  name        = "${var.resource_prefix}_rds"
  description = "For RDS MySQL traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow incoming traffic from API Server"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.web.id, aws_security_group.bastion.id]
  }

  egress {
    description      = "All outgoing traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags
}

resource "aws_security_group" "bastion" {
  name        = "${var.resource_prefix}_bastion"
  description = "For Bastion host"
  vpc_id      = module.vpc.vpc_id

  tags = var.tags
}

resource "aws_security_group_rule" "bastion_allow_ssh_inbound" {
  description = "Allow all incoming SSH traffic"
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "bastion_allow_all_outbound" {
  description = "All outgoing traffic"
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.bastion.id
}

module "bastion_consul_security_group_rules" {
  source = "git::git@github.com:hashicorp/terraform-aws-consul.git//modules/consul-client-security-group-rules?ref=v0.11.0"
  security_group_id = aws_security_group.bastion.id
  allowed_inbound_cidr_blocks = [var.cidr]
}

resource "aws_security_group" "consul" {
  name        = "${var.resource_prefix}_consul"
  description = "For Consul cluster"
  vpc_id      = module.vpc.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

resource "aws_security_group_rule" "consul_allow_ssh_inbound" {
  description = "Allow incoming SSH traffic from Bastion"
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id = aws_security_group.consul.id
}

resource "aws_security_group_rule" "consul_allow_all_outbound" {
  description = "All outgoing traffic"
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.consul.id
}

module "consul_consul_security_group_rules" {
  source = "git::git@github.com:hashicorp/terraform-aws-consul.git//modules/consul-security-group-rules?ref=v0.11.0"
  security_group_id = aws_security_group.consul.id
  allowed_inbound_cidr_blocks = [var.cidr]
}