variable "resource_prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "key_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "sg_id" {
  type = string
}