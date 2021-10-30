variable "region" {
  type = string
}

variable "resource_prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "tsdb_ami" {
  type = string
}

variable "tsdb_instance_type" {
  type = string
}

variable "sg_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "user_data" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "volume_size" {
  type = number
}

variable "cluster_size" {
  type = number
}

variable "instance_profile" {
  type = string
}