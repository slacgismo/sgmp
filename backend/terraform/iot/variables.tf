variable "region" {
  type = string
}

variable "resource_prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "subnet_ids" {
  type = list(string)
}

variable "lambda_sg_id" {
  type = string
}

variable "consul_dns" {
  type = string
}

variable "tsdb_password" {
  type = string
}

variable "tsdb_user" {
  type = string
  default = "postgres"
}

variable "tsdb_name" {
  type = string
  default = "sgmp"
}