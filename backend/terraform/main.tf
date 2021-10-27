module "network" {
  source = "./network"

  region = var.region
  resource_prefix = var.resource_prefix
  tags = var.tags
}

module "iot" {
  source = "./iot"
  
  region = var.region
  resource_prefix = var.resource_prefix
  tags = var.tags
  tsdb_host = "1.2.3.4"
  tsdb_password = "supersecurepassword"
  subnet_ids = module.network.private_subnets
  lambda_sg_id = module.network.lambda_sg_id
}

module "tsdb" {
  source = "./tsdb"

  region = var.region
  resource_prefix = var.resource_prefix
  tags = var.tags
}