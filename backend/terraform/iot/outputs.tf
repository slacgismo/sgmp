output "iot_certificate_id" {
  value = split("/", aws_iot_certificate.backend_cert.arn)[1]
}

output "iot_certificate" {
  value = aws_iot_certificate.backend_cert.certificate_pem
}

output "iot_private_key" {
  value = aws_iot_certificate.backend_cert.private_key
}

output "iot_public_key" {
  value = aws_iot_certificate.backend_cert.public_key
}

data "aws_iot_endpoint" "endpoint" {}
output "iot_endpoint" {
  value = data.aws_iot_endpoint.endpoint.endpoint_address
}