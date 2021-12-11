output "iot_certificate_id" {
  value = split("/", aws_iot_certificate.backend_cert.arn)[1]
}

output "iot_certificate" {
  value = aws_iot_certificate.backend_cert.certificate_pem
}

data "aws_iot_endpoint" "endpoint" {}
output "iot_endpoint" {
  value = data.aws_iot_endpoint.endpoint.endpoint_address
}

output "iot_private_key_arn" {
  value = aws_secretsmanager_secret.private_key.arn
}