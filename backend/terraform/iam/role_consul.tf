resource "aws_iam_role" "consul" {
  name        = "${var.resource_prefix}_consul"
  description = "Role that will be attached to the Consul cluster EC2 instances"

  assume_role_policy = data.aws_iam_policy_document.ec2_instance.json

  tags = var.tags
}

resource "aws_iam_instance_profile" "consul" {
  name = "${var.resource_prefix}_consul"
  role = aws_iam_role.consul.name
}

resource "aws_iam_role_policy_attachment" "consul_consul_peer_discovery" {
  role       = aws_iam_role.consul.name
  policy_arn = aws_iam_policy.consul_peer_discovery.arn
}
