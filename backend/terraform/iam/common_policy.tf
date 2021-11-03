// ### Policies ###
resource "aws_iam_policy" "consul_peer_discovery" {
  name        = "${var.resource_prefix}_consul_peer_discovery"
  description = "Policy that allows Consul nodes to discover peers by EC2 Instance tags and Auto Scaling Group"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "autoscaling:DescribeAutoScalingGroups"
        ],
        Resource = ["*"]
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "read_secrets" {
  name        = "${var.resource_prefix}_read_secrets"
  description = "Policy that allows roles to read Secret Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = [data.aws_secretsmanager_secret.db_credentials.arn]
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "web_services" {
  name        = "${var.resource_prefix}_web_services"
  description = "Policy that allows backend API to access required AWS resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "iot:*",
          "cognito-identity:*",
          "cognito-idp:*",
          "cognito-sync:*"
        ],
        Resource = ["*"]
      }
    ]
  })

  tags = var.tags
}