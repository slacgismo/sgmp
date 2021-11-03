resource "aws_ecs_cluster" "this" {
  name               = "${var.resource_prefix}_web"
  capacity_providers = ["FARGATE"]
  tags               = var.tags
}

module "staging" {
  source = "./service"
  name = "staging"
  resource_prefix = var.resource_prefix
  tags = var.tags
  ecs_cluster_arn = aws_ecs_cluster.this.arn
  desired_count = var.staging_desired_count
  subnet_ids = var.subnet_ids
  sg_id = var.sg_id
  vpc_id = var.vpc_id
  image_uri = var.staging_image_uri
  consul_dns = var.consul_dns
  task_role_policy_arn = var.task_role_policy_arn
  execution_role_policy_arn = var.execution_role_policy_arn
}