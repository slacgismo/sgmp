locals {
  nlb_normalized_name = replace("${var.resource_prefix}-consul", "_", "-")
}

resource "aws_lb" "nlb" {
  name = local.nlb_normalized_name
  internal = true
  load_balancer_type = "network"
  subnets = var.subnet_ids
  tags = var.tags
}

resource "aws_lb_target_group" "consul" {
  name = local.nlb_normalized_name
  port     = 8600
  protocol = "UDP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "dns" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "53"
  protocol          = "UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consul.arn
  }
}

resource "aws_autoscaling_attachment" "attachment" {
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.id
  alb_target_group_arn   = aws_lb_target_group.consul.arn
}

output "consul_dns" {
  value = aws_lb.nlb.dns_name
}