resource "aws_ecs_service" "this" {
  name            = "${var.resource_prefix}_${var.name}"
  cluster         = var.ecs_cluster_arn
  task_definition = module.staging_task.task_definition_arn
  desired_count   = var.desired_count

  network_configuration {
    subnets = var.subnet_ids
  }

  launch_type    = "FARGATE"
  propagate_tags = "TASK_DEFINITION"

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "sgmp_web"
    container_port   = 80
  }

  enable_execute_command = true
  tags = var.tags
}

module "staging_task" {
  source  = "github.com/hashicorp/terraform-aws-consul-ecs//modules/mesh-task?ref=v0.2.0-beta2"
  family  = "${var.resource_prefix}-${var.name}"

  container_definitions = [
    {
      name         = "sgmp_web"
      image        = var.image_uri
      essential    = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ]

  cpu = 512
  memory = 1024

  port       = "80"
  retry_join = var.consul_dns

  additional_execution_role_policies = [var.execution_role_policy_arn]
  additional_task_role_policies = [var.task_role_policy_arn]

  tags = var.tags
}