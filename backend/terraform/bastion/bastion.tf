data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

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
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  key_name = var.key_name

  subnet_id = var.subnet_id
  vpc_security_group_ids = [var.sg_id]

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