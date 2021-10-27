data "aws_iam_role" "lambda" {
  name = "lambda-role"
}

resource "aws_lambda_function" "ingest" {
  filename = "sgmp_ingest.zip"
  function_name = "${var.resource_prefix}_ingest"
  role = data.aws_iam_role.lambda.arn
  runtime = "python3.8"
  handler = "lambda_function"
  tags = var.tags

  environment {
    variables = {
      PG_HOST = var.tsdb_host
      PG_USER = var.tsdb_user
      PG_PASS = var.tsdb_password
      PG_NAME = var.tsdb_name
    }
  }

  vpc_config {
    subnet_ids = var.subnet_ids
    security_group_ids = [var.lambda_sg_id]
  }
}