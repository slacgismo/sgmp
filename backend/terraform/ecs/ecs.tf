resource "aws_ecs_cluster" "this" {
  name               = var.resource_prefix
  capacity_providers = ["FARGATE"]
  tags               = var.tags
}

output "cluster_arn" {
  value = aws_ecs_cluster.this.arn
}