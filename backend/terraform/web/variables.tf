variable "resource_prefix" {
  type = string
}

variable "region" {
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

variable "subnet_ids" {
  type = list(string)
}

variable "staging_image_uri" {
  type = string
}

variable "staging_desired_count" {
  type = number
}

variable "staging_cpu" {
  type = number
}

variable "staging_memory" {
  type = number
}

variable "production_image_uri" {
  type = string
}

variable "production_desired_count" {
  type = number
}

variable "production_cpu" {
  type = number
}

variable "production_memory" {
  type = number
}

variable "ecs_cluster_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "mysql_host" {
  type = string
}

variable "iot_certificate_id" {
  type = string
}

variable "iot_endpoint" {
  type = string
}

variable "iot_private_key_arn" {
  type = string
}

variable "cognito_user_pool_id" {
  type = string
}

variable "cognito_app_client_id" {
  type = string
}