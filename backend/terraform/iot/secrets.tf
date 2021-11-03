resource "aws_secretsmanager_secret" "private_key" {
  name = "${var.resource_prefix}_iot_backend_key"
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "private_key" {
  secret_id     = aws_secretsmanager_secret.private_key.id
  secret_string = aws_iot_certificate.backend_cert.private_key
}

resource "aws_iam_policy" "read_secrets" {
  name        = "${var.resource_prefix}_read_iot_private_key"
  description = "Policy that allows roles to read IoT private key from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = [aws_secretsmanager_secret.private_key.arn]
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_web_task_read_secrets" {
  role       = split("/", var.ecs_web_task_role_arn)[1]
  policy_arn = aws_iam_policy.read_secrets.arn
}