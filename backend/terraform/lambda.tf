data "aws_iam_role" "lambda" {
  name = "lambda-role"
}

resource "aws_lambda_function" "ingest" {
  filename = "sgmp_ingest.zip"
  function_name = "${local.resource_prefix}_ingest"
  role = data.aws_iam_role.lambda.arn
  runtime = "python3.8"
  tags = local.tags

  environment {
    variables = {
      PG_HOST = "1.2.3.4"
      PG_USER = "postgres"
      PG_PASS = random_password.tsdb_password.result
      PG_NAME = "sgmp"
    }
  }
}