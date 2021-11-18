module "network" {
  source = "./network"

  region          = var.region
  resource_prefix = var.resource_prefix
  tags            = var.tags

  cidr               = var.cidr
  availability_zones = var.availability_zones
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
}

module "cognito" {
  source = "./cognito"

  resource_prefix = var.resource_prefix
  tags            = var.tags
}

module "iam" {
  source = "./iam"

  region          = var.region
  resource_prefix = var.resource_prefix
  tags            = var.tags
}

module "ecs" {
  source = "./ecs"

  resource_prefix = var.resource_prefix
  tags            = var.tags
}

module "bastion" {
  source     = "./bastion"
  depends_on = [module.network]

  key_name         = var.key_name
  resource_prefix  = var.resource_prefix
  tags             = var.tags
  instance_type    = var.bastion_instance_type
  ami_id           = var.bastion_ami
  subnet_id        = module.network.public_subnets[0]
  sg_id            = module.network.bastion_sg_id
  instance_profile = module.iam.bastion_profile_name

  user_data = <<-EOF
              #!/bin/bash
              /opt/consul/bin/run-consul --client --cluster-tag-key consul-servers --cluster-tag-value auto-join
              apt-get update
              apt-get install -y mysql-client postgresql-client
              EOF
}

module "iot" {
  source = "./iot"

  region          = var.region
  resource_prefix = var.resource_prefix
  tags            = var.tags
  subnet_ids      = module.network.public_subnets
  lambda_sg_id    = module.network.lambda_sg_id
  lambda_role_arn = module.iam.lambda_role_arn

  ecs_web_task_role_arn = module.iam.ecs_web_task_role_arn
}

module "consul" {
  source = "./consul"

  region           = var.region
  resource_prefix  = var.resource_prefix
  tags             = var.tags
  ami_id           = var.consul_ami
  sg_id            = module.network.consul_sg_id
  instance_type    = var.consul_instance_type
  key_name         = var.key_name
  subnet_ids       = module.network.public_subnets
  vpc_id           = module.network.vpc_id
  instance_profile = module.iam.consul_profile_name
  replicas_per_az  = var.consul_replicas_per_az
}

module "tsdb" {
  source = "./tsdb"

  region          = var.region
  resource_prefix = var.resource_prefix
  tags            = var.tags

  tsdb_ami           = var.tsdb_ami
  tsdb_instance_type = var.tsdb_instance_type
  instance_profile   = module.iam.tsdb_profile_name
  sg_id              = module.network.tsdb_sg_id
  key_name           = var.key_name
  subnet_ids         = module.network.public_subnets
  user_data = templatefile("tsdb_provision.sh", {
    resource_prefix = var.resource_prefix,
    region          = var.region,
    cidr            = var.cidr
  })
  volume_size  = var.tsdb_volume_size
  cluster_size = var.tsdb_cluster_size
}

module "rds" {
  source = "./rds"

  region          = var.region
  resource_prefix = var.resource_prefix
  tags            = var.tags

  instance_type        = var.rds_instance_type
  sg_id                = module.network.rds_sg_id
  subnet_ids           = module.network.private_subnets
  engine_version       = var.rds_engine_version
  major_engine_version = var.rds_major_engine_version
  allocated_storage    = var.rds_allocated_storage
  password             = random_password.rds.result
  delete_protection    = var.rds_delete_protection
  multi_az             = var.rds_multi_az
}

module "web" {
  source     = "./web"
  depends_on = [module.network, module.consul]

  region                = var.region
  resource_prefix       = var.resource_prefix
  tags                  = var.tags
  # staging_subnet_id     = module.network.public_subnets[0]

  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.public_subnets

  staging_desired_count = var.staging_desired_count
  staging_image_uri     = var.staging_image_uri
  staging_cpu           = var.staging_cpu
  staging_memory        = var.staging_memory

  production_desired_count = var.production_desired_count
  production_image_uri     = var.production_image_uri
  production_cpu           = var.production_cpu
  production_memory        = var.production_memory

  ecs_cluster_arn = module.ecs.cluster_arn
  mysql_host      = module.rds.dns

  iot_certificate_id  = module.iot.iot_certificate_id
  iot_endpoint        = module.iot.iot_endpoint
  iot_private_key_arn = module.iot.iot_private_key_arn

  cognito_user_pool_id  = module.cognito.user_pool_id
  cognito_app_client_id = module.cognito.app_client_id

  task_role_arn      = module.iam.ecs_web_task_role_arn
  execution_role_arn = module.iam.ecs_web_execution_role_arn

  sg_id = module.network.web_sg_id

  acm_certificate_arn = module.certificates.acm_certificate_arn
}

data "aws_lb" "staging_api" {
  arn = module.web.staging_lb_arn
}

data "aws_lb" "production_api" {
  arn = module.web.production_lb_arn
}

module "dns_zone" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 2.0"

  zones = {
    "${var.dns_zone_name}" = {
      comment = "SGMP Route 53 Zone"
    }
  }

  tags = var.tags
}

module "dns_records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = keys(module.dns_zone.route53_zone_zone_id)[0]

  records = [
    {
      name    = "api"
      type    = "A"
      alias   = {
        name    = data.aws_lb.production_api.dns_name
        zone_id = data.aws_lb.production_api.zone_id
      }
    },
    {
      name    = "api-staging"
      type    = "A"
      alias   = {
        name    = data.aws_lb.staging_api.dns_name
        zone_id = data.aws_lb.staging_api.zone_id
      }
    },
  ]

  depends_on = [module.dns_zone]
}

module "certificates" {
  source = "./certificates"

  depends_on = [module.dns_zone]

  zone_name = var.dns_zone_name
  tags = var.tags
}

output "bastion_ip" {
  value = module.bastion.bastion_ip
}