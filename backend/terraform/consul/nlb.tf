locals {
  nlb_normalized_name = replace("${var.resource_prefix}-consul", "_", "-")
}

resource "aws_lb" "nlb" {
  name               = local.nlb_normalized_name
  internal           = true
  load_balancer_type = "network"
  subnets            = var.subnet_ids
  tags               = var.tags
}

resource "aws_lb_target_group" "consul_dns" {
  name                 = "${local.nlb_normalized_name}-dns"
  port                 = 8600
  protocol             = "UDP"
  vpc_id               = var.vpc_id
  deregistration_delay = 60
}

resource "aws_lb_target_group" "consul_http" {
  name                 = "${local.nlb_normalized_name}-http"
  port                 = 8500
  protocol             = "TCP"
  vpc_id               = var.vpc_id
  deregistration_delay = 60
}

resource "aws_lb_listener" "dns" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "53"
  protocol          = "UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consul_dns.arn
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "8500"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consul_http.arn
  }
}

resource "aws_autoscaling_attachment" "attachment_dns" {
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.id
  alb_target_group_arn   = aws_lb_target_group.consul_dns.arn
}

resource "aws_autoscaling_attachment" "attachment_http" {
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.id
  alb_target_group_arn   = aws_lb_target_group.consul_http.arn
}

output "consul_dns" {
  value = aws_lb.nlb.dns_name
}