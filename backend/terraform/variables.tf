variable "region" {
  type = string
}

variable "tsdb_ami" {
  type = string
  default = "ami-06c8b069341adfbd2"
}

variable "tsdb_instance_type" {
  type = string
  default = "t3.medium"
}

variable "mysql_ami" {
  type = string
  default = "ami-0ed6cf767dd20fcf3"
}

variable "mysql_instance_type" {
  type = string
  default = "t3.medium"
}