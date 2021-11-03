variable "resource_prefix" {
  type = string
}

variable "region" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "name" {
  type = string
}

variable "ecs_cluster_arn" {
  type = string
}

variable "desired_count" {
  type = number
}

variable "subnet_ids" {
  type = list(string)
}

variable "sg_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "image_uri" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "cpu" {
  type = number
}

variable "memory" {
  type = number
}

variable "database_credentials_arn" {
  type = string
}

variable "iot_private_key_arn" {
  type = string
}

variable "iot_certificate_id" {
  type = string
}

variable "iot_endpoint" {
  type = string
}

variable "mysql_host" {
  type = string
}

variable "cognito_user_pool_id" {
  type = string
}

variable "cognito_app_client_id" {
  type = string
}