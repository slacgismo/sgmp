resource "aws_iam_role" "lambda" {
  name        = "${var.resource_prefix}_lambda"
  description = "Role that will be attached to the Lambda function"

  assume_role_policy = data.aws_iam_policy_document.lambda.json

  tags = var.tags
}

resource "aws_iam_policy" "create_interfaces" {
  name        = "${var.resource_prefix}_create_interfaces"
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

resource "aws_iam_role_policy_attachment" "lambda_create_interfaces" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.create_interfaces.arn
}

resource "aws_iam_role_policy_attachment" "lambda_consul_peer_discovery" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.consul_peer_discovery.arn
}

resource "aws_iam_role_policy_attachment" "lambda_read_secrets" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.read_secrets.arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_xray" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}