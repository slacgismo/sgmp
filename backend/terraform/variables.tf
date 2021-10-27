variable "region" {
  type = string
}

variable "resource_prefix" {
  type = string
  default = "gismolab_sgmp"
}

variable "tags" {
  type = map(string)
  default = {
    Project = "sgmp"
  }
}