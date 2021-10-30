resource "aws_eip" "bastion" {
  vpc = true
  tags = merge(var.tags, {
    Name = "${var.resource_prefix}_bastion"
  })
}

resource "aws_eip_association" "bastion" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.bastion.id
}

resource "aws_instance" "bastion" {
  ami           = var.ami_id
  instance_type = var.instance_type

  key_name  = var.key_name
  user_data = var.user_data

  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.sg_id]
  iam_instance_profile   = var.instance_profile

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}_bastion"
  })
  volume_tags = merge(var.tags, {
    Name = "${var.resource_prefix}_bastion"
  })
}

output "bastion_ip" {
  value = aws_eip.bastion.public_ip
}