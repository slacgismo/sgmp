resource "aws_iam_role" "ecs_web_execution" {
  name        = "${var.resource_prefix}_web_execution"
  description = "Role that will be assumed by ECS Docker daemon to pull image and retrieve secret"

  assume_role_policy = data.aws_iam_policy_document.ecs.json

  tags = var.tags
}

resource "aws_iam_role" "ecs_web_task" {
  name        = "${var.resource_prefix}_web_task"
  description = "Role that will be assumed by web service ECS containers"

  assume_role_policy = data.aws_iam_policy_document.ec2_and_ecs.json

  tags = var.tags
}

resource "aws_iam_policy" "ecs_web_execution" {
  name        = "${var.resource_prefix}_ecs_web_execution"
  description = "Policy that allows ECS to pull ECR image and push logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_web_execution_ecs_web_execution" {
  role       = aws_iam_role.ecs_web_execution.name
  policy_arn = aws_iam_policy.ecs_web_execution.arn
}

resource "aws_iam_role_policy_attachment" "ecs_web_execution_read_secrets" {
  role       = aws_iam_role.ecs_web_execution.name
  policy_arn = aws_iam_policy.read_secrets.arn
}

resource "aws_iam_role_policy_attachment" "ecs_web_task_web_services" {
  role       = aws_iam_role.ecs_web_task.name
  policy_arn = aws_iam_policy.web_services.arn
}

resource "aws_iam_role_policy_attachment" "ecs_web_task_consul_peer_discovery" {
  role       = aws_iam_role.ecs_web_task.name
  policy_arn = aws_iam_policy.consul_peer_discovery.arn
}
