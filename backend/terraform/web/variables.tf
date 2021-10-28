variable "resource_prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "key_name" {
  type = string
}

variable "staging_instance_type" {
  type = string
}

variable "staging_ami" {
  type = string
}

variable "staging_subnet_id" {
  type = string
}

variable "sg_id" {
  type = string
}

variable "user_data" {
  type = string
}