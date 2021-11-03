// ### Roles ###
resource "aws_iam_role" "web" {
  name        = "${var.resource_prefix}_web"
  description = "Role that will be attached to the backend API ECS Task"

  assume_role_policy = data.aws_iam_policy_document.ec2_and_ecs.json

  tags = var.tags
}

// ### Instance profiles ###
resource "aws_iam_instance_profile" "web" {
  name = "${var.resource_prefix}_web"
  role = aws_iam_role.web.name
}

// ### Policy attachments ###
resource "aws_iam_role_policy_attachment" "web_consul_peer_discovery" {
  role       = aws_iam_role.web.name
  policy_arn = aws_iam_policy.consul_peer_discovery.arn
}

resource "aws_iam_role_policy_attachment" "web_web_services" {
  role       = aws_iam_role.web.name
  policy_arn = aws_iam_policy.web_services.arn
}

resource "aws_iam_role_policy_attachment" "web_read_secrets" {
  role       = aws_iam_role.web.name
  policy_arn = aws_iam_policy.read_secrets.arn
}