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
  default = "ami-06c8b069341adfbd2"
}

variable "tsdb_instance_type" {
  type = string
  default = "t3.medium"
}