data "aws_iam_role" "lambda" {
  name = "lambda-role"
}

resource "aws_lambda_function" "ingest" {
  filename         = "sgmp_ingest.zip"
  function_name    = "${var.resource_prefix}_ingest"
  source_code_hash = filebase64sha256("sgmp_ingest.zip")
  role             = data.aws_iam_role.lambda.arn
  runtime          = "python3.8"
  handler          = "lambda_function.lambda_handler"
  tags             = var.tags

  environment {
    variables = {
      CONSUL_DNS  = var.consul_dns
      PG_USER     = var.tsdb_user
      PG_PASS     = var.tsdb_password
      PG_DATABASE = var.tsdb_name
    }
  }

  vpc_config {
    subnet_ids = var.subnet_ids
    security_group_ids = [var.lambda_sg_id]
  }
}

resource "aws_lambda_permission" "allow_iot" {
  statement_id  = "AllowExecutionFromIoT"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ingest.function_name
  principal     = "iot.amazonaws.com"
  source_arn    = aws_iot_topic_rule.rule.arn
}