# This file was autogenerated by the 'packer hcl2_upgrade' command. We
# recommend double checking that everything is correct before going forward. We
# also recommend treating this file as disposable. The HCL2 blocks in this
# file can be moved to other files. For example, the variable blocks could be
# moved to their own 'variables.pkr.hcl' file, etc. Those files need to be
# suffixed with '.pkr.hcl' to be visible to Packer. To use multiple files at
# once they also need to be in the same folder. 'packer inspect folder/'
# will describe to you what is in that folder.

# Avoid mixing go templating calls ( for example ```{{ upper(`string`) }}``` )
# and HCL2 calls (for example '${ var.string_value_example }' ). They won't be
# executed together and the outcome will be unknown.

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

variable "account_id" {
  type = string
  default = "041414866712"
}

variable "go_version" {
  type = string
  default = "1.16.9"
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "amazon-ebs" "ubuntu" {
  ami_description             = "An Ubuntu AMI that has Consul client and SGMP ingest server installed."
  ami_name                    = "sgmp-ingest-ubuntu-${uuidv4()}"
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
    owners      = [var.account_id] # Canonical
  }
  ssh_username = "ubuntu"
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = ["mkdir /tmp/sgmp_ingest"]
  }

  provisioner "file" {
    source = "./"
    destination = "/tmp/sgmp_ingest"
  }

  provisioner "shell" {
    inline = [
      "cd /tmp",
      "wget https://golang.org/dl/go${var.go_version}.linux-amd64.tar.gz -O go.tar.gz",
      "sudo tar -C /usr/local -xf go.tar.gz",
      "export PATH=$PATH:/usr/local/go/bin",
      "cd /tmp/sgmp_ingest",
      "go get -u",
      "go build .",
      "sudo cp /tmp/sgmp_ingest/sgmp_ingest /opt/",
    ]
  }

}