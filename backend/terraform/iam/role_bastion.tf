resource "aws_iam_role" "bastion" {
  name        = "${var.resource_prefix}_bastion"
  description = "Role that will be attached to the Bastion instances"

  assume_role_policy = data.aws_iam_policy_document.ec2_instance.json

  tags = var.tags
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.resource_prefix}_bastion"
  role = aws_iam_role.bastion.name
}

resource "aws_iam_role_policy_attachment" "bastion_consul_peer_discovery" {
  role       = aws_iam_role.bastion.name
  policy_arn = aws_iam_policy.consul_peer_discovery.arn
}