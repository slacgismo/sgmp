module "rds" {
  source = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier = replace(var.resource_prefix, "_", "-")

  engine = "mysql"
  engine_version = var.engine_version
  major_engine_version = var.major_engine_version
  instance_class = var.instance_type
  allocated_storage = var.allocated_storage
  multi_az = var.multi_az

  name = "sgmp"
  username = "sgmp"
  password = var.password
  port = "3306"

  vpc_security_group_ids = [var.sg_id]
  subnet_ids = var.subnet_ids

  deletion_protection = var.delete_protection
  allow_major_version_upgrade = true

  parameters = [
    {
      name = "character_set_client"
      value = "utf8mb4"
    },
    {
      name = "character_set_server"
      value = "utf8mb4"
    }
  ]
  family = "mysql${var.major_engine_version}"

  tags = var.tags
}

output "dns" {
  value = module.rds.db_instance_address
}