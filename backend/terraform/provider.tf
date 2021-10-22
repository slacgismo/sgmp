terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.63.0"
    }
  }

  backend "s3" {
    bucket = "sgmp-terraform-state"
    key    = "state"
    region = "us-west-1"
  }
}

provider "aws" {
  region = var.region
}