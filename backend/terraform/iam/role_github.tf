resource "aws_iam_role" "github" {
  name        = "${var.resource_prefix}_github_actions"
  description = "Role that will be assumed by GitHub Actions to perform CI actions"

  assume_role_policy = data.aws_iam_policy_document.github_assume_role_policy.json

  tags = var.tags
}

resource "aws_iam_policy" "github_actions" {
  name        = "${var.resource_prefix}_github_actions"
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

resource "aws_iam_role_policy_attachment" "github_github_actions" {
  role       = aws_iam_role.github.name
  policy_arn = aws_iam_policy.github_actions.arn
}