data "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.resource_prefix}_credentials"
}

module "staging" {
  source                   = "./service"
  name                     = "staging"
  resource_prefix          = var.resource_prefix
  tags                     = var.tags
  ecs_cluster_arn          = var.ecs_cluster_arn
  desired_count            = var.staging_desired_count
  subnet_ids               = var.subnet_ids
  sg_id                    = var.sg_id
  vpc_id                   = var.vpc_id
  image_uri                = var.staging_image_uri
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.execution_role_arn
  region                   = var.region
  cpu                      = var.staging_cpu
  memory                   = var.staging_memory
  mysql_host               = var.mysql_host
  database_credentials_arn = data.aws_secretsmanager_secret.db_credentials.arn
  iot_private_key_arn      = var.iot_private_key_arn
  iot_certificate_id       = var.iot_certificate_id
  iot_endpoint             = var.iot_endpoint
  cognito_user_pool_id     = var.cognito_user_pool_id
  cognito_app_client_id    = var.cognito_app_client_id
}

module "production" {
  source                   = "./service"
  name                     = "production"
  resource_prefix          = var.resource_prefix
  tags                     = var.tags
  ecs_cluster_arn          = var.ecs_cluster_arn
  desired_count            = var.production_desired_count
  subnet_ids               = var.subnet_ids
  sg_id                    = var.sg_id
  vpc_id                   = var.vpc_id
  image_uri                = var.production_image_uri
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.execution_role_arn
  region                   = var.region
  cpu                      = var.production_cpu
  memory                   = var.production_memory
  mysql_host               = var.mysql_host
  database_credentials_arn = data.aws_secretsmanager_secret.db_credentials.arn
  iot_private_key_arn      = var.iot_private_key_arn
  iot_certificate_id       = var.iot_certificate_id
  iot_endpoint             = var.iot_endpoint
  cognito_user_pool_id     = var.cognito_user_pool_id
  cognito_app_client_id    = var.cognito_app_client_id
}