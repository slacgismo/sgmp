resource "aws_eip" "staging" {
  vpc = true
  tags = merge(var.tags, {
    Name = "${var.resource_prefix}_staging"
  })
}

resource "aws_eip_association" "staging" {
  instance_id   = aws_instance.staging.id
  allocation_id = aws_eip.staging.id
}

resource "aws_instance" "staging" {
  ami           = var.staging_ami
  instance_type = var.staging_instance_type

  key_name = var.key_name

  subnet_id              = var.staging_subnet_id
  vpc_security_group_ids = [var.sg_id]

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}_web_staging"
  })
  volume_tags = merge(var.tags, {
    Name = "${var.resource_prefix}_web_staging"
  })

  user_data = var.user_data

  iam_instance_profile = "SGMP_EC2"
}

output "staging_ip" {
  value = aws_eip.staging.public_ip
}