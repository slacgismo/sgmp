resource "aws_iam_role" "tsdb" {
  name        = "${var.resource_prefix}_tsdb"
  description = "Role that will be attached to the TimescaleDB cluster EC2 instances"

  assume_role_policy = data.aws_iam_policy_document.ec2_instance.json

  tags = var.tags
}

resource "aws_iam_instance_profile" "tsdb" {
  name = "${var.resource_prefix}_tsdb"
  role = aws_iam_role.tsdb.name
}

resource "aws_iam_role_policy_attachment" "tsdb_consul_peer_discovery" {
  role       = aws_iam_role.tsdb.name
  policy_arn = aws_iam_policy.consul_peer_discovery.arn
}

resource "aws_iam_role_policy_attachment" "tsdb_read_secrets" {
  role       = aws_iam_role.tsdb.name
  policy_arn = aws_iam_policy.read_secrets.arn
}