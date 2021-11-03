variable "region" {
  type = string
}

variable "cidr" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "resource_prefix" {
  type    = string
  default = "gismolab_sgmp"
}

variable "dns_zone_name" {
  type = string
}

variable "tags" {
  type = map(string)
  default = {
    Project = "sgmp"
  }
}

variable "key_name" {
  type = string
}

variable "bastion_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "consul_ami" {
  type    = string
  default = "ami-029139ef905224a72"
}

variable "consul_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "consul_replicas_per_az" {
  type    = number
  default = 1
}

variable "tsdb_ami" {
  type    = string
  default = "ami-0cc7deef96971c4b0"
}

variable "tsdb_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "tsdb_volume_size" {
  type = number
}

variable "tsdb_cluster_size" {
  type = number
}

variable "rds_instance_type" {
  type    = string
  default = "db.t3.micro"
}

variable "rds_allocated_storage" {
  type = number
}

variable "rds_engine_version" {
  type = string
}

variable "rds_major_engine_version" {
  type = string
}

variable "rds_delete_protection" {
  type    = bool
  default = true
}

variable "rds_multi_az" {
  type    = string
  default = true
}

variable "staging_instance_type" {
  type    = string
  default = "t3.small"
}

variable "staging_ami" {
  type    = string
  default = "ami-029139ef905224a72"
}

variable "staging_desired_count" {
  type    = number
  default = 1
}

variable "staging_cpu" {
  type    = number
  default = 512
}

variable "staging_memory" {
  type    = number
  default = 1024
}

variable "production_image_uri" {
  type = string
}

variable "production_desired_count" {
  type    = number
  default = 4
}

variable "production_cpu" {
  type    = number
  default = 1024
}

variable "production_memory" {
  type    = number
  default = 2048
}

variable "staging_image_uri" {
  type = string
}

variable "bastion_ami" {
  type    = string
  default = "ami-029139ef905224a72"
}