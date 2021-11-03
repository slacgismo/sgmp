resource "aws_cloudwatch_log_group" "this" {
  name = "${var.resource_prefix}_${var.name}"
  tags = var.tags
}