variable "region" {
  type = string
}

variable "resource_prefix" {
  type = string
}

variable "lambda_role_arn" {
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