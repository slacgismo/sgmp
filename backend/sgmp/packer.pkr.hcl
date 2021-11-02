# See https://www.packer.io/docs/templates/hcl_templates/blocks/packer for more info
packer {
  required_version = ">= 1.5.4"
}

# All generated input variables will be of 'string' type as this is how Packer JSON
# views them; you can change their type later on. Read the variables type
# constraints documentation
# https://www.packer.io/docs/templates/hcl_templates/variables#type-constraints for more info.
variable "aws_region" {
  type    = string
  default = "us-west-1"
}

variable "module_version" {
  type    = string
  default = "0.11.0"
}

variable "consul_version" {
  type    = string
  default = "1.9.2"
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "amazon-ebs" "ubuntu" {
  ami_description             = "An Ubuntu AMI that has SGMP backend installed."
  ami_name                    = "sgmp-web-ubuntu-${uuidv4()}"
  instance_type               = "t2.micro"
  region                      = "${var.aws_region}"
  associate_public_ip_address = true
  source_ami_filter {
    filters = {
      name                = "consul-ubuntu-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["041414866712"] # slac-gismo
  }
  ssh_username = "ubuntu"
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell-local" {
    inline = ["rm -f deploy.tar.gz", "tar -czvf deploy.tar.gz --exclude=__pycache__ app.py requirements.txt migrations models routes utils"]
  }

  provisioner "file" {
    source = "deploy.tar.gz"
    destination = "/tmp/deploy.tar.gz"
    generated = true
  }

  provisioner "shell" {
    inline = [
      "sleep 60", # Make sure cloud-init has finished its job
      "sudo apt-get update",
      "sudo apt-get install -y python3-pip libpq-dev libmysqlclient-dev"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo mkdir /opt/sgmp",
      "cd /opt/sgmp",
      "sudo mv /tmp/deploy.tar.gz ./",
      "sudo tar -xvf deploy.tar.gz",
      "sudo pip install -r requirements.txt",
      "sudo pip install gunicorn",
      "sudo groupadd -r sgmp",
      "sudo useradd -r -g sgmp -d /opt/sgmp sgmp",
      "sudo chown -R sgmp:sgmp /opt/sgmp"
    ]
  }

  provisioner "file" {
    destination = "/tmp/gunicorn.service"
    content = <<-EOT
              [Unit]
              Description=Gunicorn
              After=network.target
              Requires=gunicorn.socket

              [Service]
              PIDFile=/tmp/gunicorn.pid
              User=sgmp
              Group=sgmp
              WorkingDirectory=/opt/sgmp
              ExecStart=gunicorn app:app -b 0.0.0.0:80 -w 8 --pid /tmp/gunicorn.pid -t 600
              ExecReload= /bin/kill -s HUP $MAINPID
              ExecStop=/bin/kill -s TERM $MAINPID

              [Install]
              WantedBy = multi-user.target
              EOT
  }

  provisioner "file" {
    destination = "/tmp/gunicorn.socket"
    content = <<-EOT
              [Unit]
              Description=Gunicorn socket

              [Socket]
              ListenStream=80
              NoDelay=true
              EOT
  }

  provisioner "shell" {
    inline = [
      "sudo mv /tmp/gunicorn.service /etc/systemd/system/gunicorn.service",
      "sudo mv /tmp/gunicorn.socket /etc/systemd/system/gunicorn.socket",
      "sudo chown root:root /etc/systemd/system/gunicorn.service",
      "sudo chown root:root /etc/systemd/system/gunicorn.socket"
    ]
  }

  provisioner "shell-local" {
    inline = ["rm -f deploy.tar.gz"]
  }

}
