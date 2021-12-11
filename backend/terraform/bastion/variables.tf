variable "resource_prefix" {
  type = string
}

variable "ami_id" {
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

variable "user_data" {
  type = string
}

variable "instance_profile" {
  type = string
}