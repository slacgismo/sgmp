resource "aws_iot_certificate" "backend_cert" {
  active = true
}

resource "aws_iot_topic_rule" "rule" {
  name        = "${var.resource_prefix}_data"
  description = "Lambda -> TimescaleDB ingest rule for SGMP"
  enabled     = true
  sql         = "SELECT * AS data, topic(2) as client_id, cast(topic(3) AS DECIMAL) as device_id, topic(4) as device_name, cast(topic(5) AS DECIMAL) as timestamp, topic(6) as topic FROM '${var.resource_prefix}_read/+/+/+/+/+'"
  sql_version = "2016-03-23"

  lambda {
    function_arn = aws_lambda_function.ingest.arn
  }

  tags = var.tags
}

resource "aws_iot_thing" "backend" {
  name = "${var.resource_prefix}_backend"
}

resource "aws_iot_policy" "backend_policy" {
  name = "${var.resource_prefix}_backend"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : "iot:Connect",
        "Resource" : "arn:aws:iot:${var.region}:${local.account_id}:client/$${iot:Connection.Thing.ThingName}"
      },
      {
        "Effect" : "Allow",
        "Action" : "iot:Publish",
        "Resource" : "arn:aws:iot:${var.region}:${local.account_id}:topic/${var.resource_prefix}_config/*"
      },
      {
        "Effect" : "Allow",
        "Action" : "iot:Publish",
        "Resource" : "arn:aws:iot:${var.region}:${local.account_id}:topic/${var.resource_prefix}_write/*"
      }
    ]
  })
}

resource "aws_iot_policy" "edge_policy" {
  name = "${var.resource_prefix}_edge"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : "iot:Connect",
        "Resource" : "arn:aws:iot:${var.region}:${local.account_id}:client/$${iot:Connection.Thing.ThingName}"
      },
      {
        "Effect" : "Allow",
        "Action" : "iot:Publish",
        "Resource" : "arn:aws:iot:${var.region}:${local.account_id}:topic/${var.resource_prefix}_read/$${iot:Connection.Thing.ThingName}/*"
      },
      {
        "Effect" : "Allow",
        "Action" : "iot:Subscribe",
        "Resource" : "arn:aws:iot:${var.region}:${local.account_id}:topicfilter/${var.resource_prefix}_config/$${iot:Connection.Thing.ThingName}/*"
      },
      {
        "Effect" : "Allow",
        "Action" : "iot:Receive",
        "Resource" : "arn:aws:iot:${var.region}:${local.account_id}:topic/${var.resource_prefix}_config/$${iot:Connection.Thing.ThingName}/*"
      },
      {
        "Effect" : "Allow",
        "Action" : "iot:Subscribe",
        "Resource" : "arn:aws:iot:${var.region}:${local.account_id}:topicfilter/${var.resource_prefix}_write/$${iot:Connection.Thing.ThingName}/*"
      },
      {
        "Effect" : "Allow",
        "Action" : "iot:Receive",
        "Resource" : "arn:aws:iot:${var.region}:${local.account_id}:topic/${var.resource_prefix}_write/$${iot:Connection.Thing.ThingName}/*"
      }
    ]
  })
}

resource "aws_iot_policy_attachment" "backend" {
  policy = aws_iot_policy.backend_policy.name
  target = aws_iot_certificate.backend_cert.arn
}

resource "aws_iot_thing_principal_attachment" "backend" {
  principal = aws_iot_certificate.backend_cert.arn
  thing     = aws_iot_thing.backend.name
}