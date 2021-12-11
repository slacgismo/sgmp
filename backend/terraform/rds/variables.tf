variable "region" {
  type = string
}

variable "resource_prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "sg_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "engine_version" {
  type = string
}

variable "major_engine_version" {
  type = string
}

variable "allocated_storage" {
  type = number
}

variable "password" {
  type = string
}

variable "delete_protection" {
  type = bool
}

variable "multi_az" {
  type = bool
}