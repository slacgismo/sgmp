data "aws_caller_identity" "current" {}

locals {
  resource_prefix = "gismolab_sgmp"
  account_id = data.aws_caller_identity.current.account_id
  tags = {
    Project = "sgmp"
  }
}