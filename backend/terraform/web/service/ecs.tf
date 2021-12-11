# Reference: https://github.com/hashicorp/terraform-aws-consul-ecs/blob/v0.2.0-beta2/modules/mesh-task/main.tf
# Adapted for SGMP usage.

locals {
  web_log_configuration = {
    logDriver = "awslogs",
    options = {
      awslogs-region        = var.region,
      awslogs-group         = "${var.resource_prefix}_${var.name}",
      awslogs-stream-prefix = "web"
    }
  }
}

resource "aws_ecs_service" "this" {
  name            = var.name
  cluster         = var.ecs_cluster_arn
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.sg_id]
    assign_public_ip = true
  }

  launch_type    = "FARGATE"
  propagate_tags = "TASK_DEFINITION"

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "sgmp-web"
    container_port   = 80
  }

  enable_execute_command = true
  tags                   = var.tags
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.resource_prefix}_${var.name}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  tags                     = merge(var.tags)
  volume {
    name = "secret-vol"
  }
  container_definitions = jsonencode(
    [
      {
        name             = "secret-sidecar"
        image            = "amazon/aws-secrets-manager-secret-sidecar:v0.1.4"
        essential        = false
        logConfiguration = local.web_log_configuration
        mountPoints = [{
          containerPath = "/tmp"
          sourceVolume  = "secret-vol"
        }]
        environment = [
          {
            name  = "SECRET_ARN"
            value = var.iot_private_key_arn
          },
          {
            name  = "SECRET_FILENAME"
            value = "iot_private_key.pem"
          }
        ]
        volumesFrom = []
      },
      {
        name      = "sgmp-web"
        image     = var.image_uri
        essential = true
        dependsOn = [{
          containerName = "secret-sidecar"
          condition     = "COMPLETE"
        }]
        mountPoints = [{
          containerPath = "/tmp"
          sourceVolume  = "secret-vol"
        }]
        logConfiguration = local.web_log_configuration
        portMappings = [
          {
            containerPort = 80
            hostPort      = 80
          }
        ]
        environment = [
          {
            name  = "TSDB_USER"
            value = "sgmp"
          },
          {
            name  = "TSDB_DATABASE"
            value = "sgmp"
          },
          {
            name  = "MYSQL_HOST"
            value = var.mysql_host
          },
          {
            name  = "MYSQL_USER"
            value = "sgmp"
          },
          {
            name  = "MYSQL_DATABASE"
            value = "sgmp"
          },
          {
            name  = "AWS_REGION"
            value = var.region
          },
          {
            name  = "IOT_CERT_ID"
            value = var.iot_certificate_id
          },
          {
            name  = "IOT_ENDPOINT"
            value = var.iot_endpoint
          },
          {
            name  = "IOT_KEY_PATH"
            value = "/tmp/iot_private_key.pem"
          },
          {
            name  = "COGNITO_USER_POOL_ID",
            value = var.cognito_user_pool_id
          },
          {
            name  = "COGNITO_APP_CLIENT_ID",
            value = var.cognito_app_client_id
          },
          {
            name  = "DEPLOYMENT_NAME"
            value = var.resource_prefix
          }
        ]
        secrets = [
          {
            name      = "TSDB_PASS"
            valueFrom = "${var.database_credentials_arn}:tsdb_sgmp::"
          },
          {
            name      = "MYSQL_PASS"
            valueFrom = "${var.database_credentials_arn}:rds::"
          }
        ]
      }
    ]
  )
}
