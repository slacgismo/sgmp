variable "region" {
  type = string
}

variable "resource_prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "replicas_per_az" {
  type = number
}

variable "ami_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "sg_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "user_data" {
  type    = string
  default = <<-EOF
            #!/bin/bash
            /opt/consul/bin/run-consul --server --cluster-tag-key consul-servers --cluster-tag-value auto-join
            EOF
}

variable "subnet_ids" {
  type = list(string)
}

variable "instance_profile" {
  type = string
}