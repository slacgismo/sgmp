data "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.resource_prefix}_credentials"
}

data "aws_ecr_repository" "repo" {
  name = "sgmp"
}