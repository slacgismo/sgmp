// Data to retrieve ECR repository ARN
data "aws_ecr_repository" "repo" {
  name = "sgmp"
}

// OIDC Provider and Role definition for GitHub Actions
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["a031c46782e6e6c662c2c87c76da9aa62ccabd8e"]

  tags = var.tags
}

resource "aws_iam_policy" "github_actions" {
  name = "${var.resource_prefix}_github_actions"
  description = "Policy that allows GitHub actions to access required resource during CI pipeline"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:ListImages"
        ],
        Resource = data.aws_ecr_repository.repo.arn
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ],
        Resource = data.aws_ecr_repository.repo.arn
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "ecs_execution" {
  name = "${var.resource_prefix}_ecs_execution"
  description = "Policy that allows ECS to pull image from ECR"

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
      },
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

resource "aws_iam_role" "github" {
  name = "${var.resource_prefix}_github_actions"
  description = "Role that will be assumed by GitHub Actions to perform CI actions"

  assume_role_policy = data.aws_iam_policy_document.github_assume_role_policy.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "github_github_actions" {
  role       = aws_iam_role.github.name
  policy_arn = aws_iam_policy.github_actions.arn
}

data "aws_iam_policy_document" "github_assume_role_policy" {
  statement {
    sid     = "GrantGithubActionsAccess"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:pdjs/sgmp:*"]
    }
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.id]
    }
  }
}