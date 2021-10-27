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
  default = 1
}

variable "ami_id" {
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
  type = string
}

variable "subnet_ids" {
  type = list(string)
}