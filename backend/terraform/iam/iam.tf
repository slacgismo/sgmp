// ### Policies ###
resource "aws_iam_policy" "consul_peer_discovery" {
  name = "${var.resource_prefix}_consul_peer_discovery"
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

resource "aws_iam_policy" "web_services" {
  name = "${var.resource_prefix}_web_services"
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

resource "aws_iam_policy" "create_interfaces" {
  name = "${var.resource_prefix}_create_interfaces"
  description = "Policy that allows Lambda to create network interfaces within VPC"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:AttachNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],
        Resource = ["*"]
      }
    ]
  })

  tags = var.tags
}

data "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.resource_prefix}_credentials"
}

resource "aws_iam_policy" "read_secrets" {
  name = "${var.resource_prefix}_read_secrets"
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

// ### Assume role policies ###
data "aws_iam_policy_document" "ec2_instance" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

// ### Roles ###
resource "aws_iam_role" "bastion" {
  name = "${var.resource_prefix}_bastion"
  description = "Role that will be attached to the Bastion instances"

  assume_role_policy = data.aws_iam_policy_document.ec2_instance.json

  tags = var.tags
}

resource "aws_iam_role" "consul" {
  name = "${var.resource_prefix}_consul"
  description = "Role that will be attached to the Consul cluster EC2 instances"

  assume_role_policy = data.aws_iam_policy_document.ec2_instance.json

  tags = var.tags
}

resource "aws_iam_role" "tsdb" {
  name = "${var.resource_prefix}_tsdb"
  description = "Role that will be attached to the TimescaleDB cluster EC2 instances"

  assume_role_policy = data.aws_iam_policy_document.ec2_instance.json

  tags = var.tags
}

resource "aws_iam_role" "web" {
  name = "${var.resource_prefix}_web"
  description = "Role that will be attached to the backend API ECS Task"

  assume_role_policy = data.aws_iam_policy_document.ec2_instance.json

  tags = var.tags
}

resource "aws_iam_role" "lambda" {
  name = "${var.resource_prefix}_lambda"
  description = "Role that will be attached to the Lambda function"

  assume_role_policy = data.aws_iam_policy_document.lambda.json

  tags = var.tags
}

// ### Instance profiles ###
resource "aws_iam_instance_profile" "bastion" {
  name = "${var.resource_prefix}_bastion"
  role = aws_iam_role.bastion.name
}

resource "aws_iam_instance_profile" "consul" {
  name = "${var.resource_prefix}_consul"
  role = aws_iam_role.consul.name
}

resource "aws_iam_instance_profile" "tsdb" {
  name = "${var.resource_prefix}_tsdb"
  role = aws_iam_role.tsdb.name
}

resource "aws_iam_instance_profile" "web" {
  name = "${var.resource_prefix}_web"
  role = aws_iam_role.web.name
}

// ### Policy attachments ###
resource "aws_iam_role_policy_attachment" "bastion_consul_peer_discovery" {
  role       = aws_iam_role.bastion.name
  policy_arn = aws_iam_policy.consul_peer_discovery.arn
}

resource "aws_iam_role_policy_attachment" "consul_consul_peer_discovery" {
  role       = aws_iam_role.consul.name
  policy_arn = aws_iam_policy.consul_peer_discovery.arn
}

resource "aws_iam_role_policy_attachment" "tsdb_consul_peer_discovery" {
  role       = aws_iam_role.tsdb.name
  policy_arn = aws_iam_policy.consul_peer_discovery.arn
}

resource "aws_iam_role_policy_attachment" "tsdb_read_secrets" {
  role       = aws_iam_role.tsdb.name
  policy_arn = aws_iam_policy.read_secrets.arn
}

resource "aws_iam_role_policy_attachment" "web_consul_peer_discovery" {
  role       = aws_iam_role.web.name
  policy_arn = aws_iam_policy.consul_peer_discovery.arn
}

resource "aws_iam_role_policy_attachment" "web_web_services" {
  role       = aws_iam_role.web.name
  policy_arn = aws_iam_policy.web_services.arn
}

resource "aws_iam_role_policy_attachment" "web_read_secrets" {
  role       = aws_iam_role.web.name
  policy_arn = aws_iam_policy.read_secrets.arn
}

resource "aws_iam_role_policy_attachment" "lambda_create_interfaces" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.create_interfaces.arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_xray" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_consul_peer_discovery" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.consul_peer_discovery.arn
}

resource "aws_iam_role_policy_attachment" "lambda_read_secrets" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.read_secrets.arn
}