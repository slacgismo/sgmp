variable "resource_prefix" {
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

variable "consul_dns" {
  type = string
}

variable "task_role_policy_arn" {
  type = string
}

variable "execution_role_policy_arn" {
  type = string
}