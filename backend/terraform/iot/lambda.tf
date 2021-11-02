resource "aws_lambda_function" "ingest" {
  filename         = "sgmp_ingest.zip"
  function_name    = "${var.resource_prefix}_ingest"
  source_code_hash = filebase64sha256("sgmp_ingest.zip")
  role             = var.lambda_role_arn
  runtime          = "python3.8"
  handler          = "lambda_function.lambda_handler"
  tags             = var.tags

  environment {
    variables = {
      RESOURCE_PREFIX = var.resource_prefix
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