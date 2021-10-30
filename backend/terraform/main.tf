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
  instance_profile = var.instance_profile

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
  consul_dns      = module.consul.consul_dns
  tsdb_password   = random_password.tsdb_postgres.result
  subnet_ids      = module.network.public_subnets
  lambda_sg_id    = module.network.lambda_sg_id
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
  instance_profile = var.instance_profile
  replicas_per_az  = var.consul_replicas_per_az
}

module "tsdb" {
  source = "./tsdb"

  region          = var.region
  resource_prefix = var.resource_prefix
  tags            = var.tags

  tsdb_ami           = var.tsdb_ami
  tsdb_instance_type = var.tsdb_instance_type
  instance_profile   = var.instance_profile
  sg_id              = module.network.tsdb_sg_id
  key_name           = var.key_name
  subnet_ids         = module.network.public_subnets
  user_data = templatefile("tsdb_provision.sh", {
    replicator_password = random_password.tsdb_replicator.result,
    postgres_password   = random_password.tsdb_postgres.result,
    rewind_password     = random_password.tsdb_rewind_user.result,
    cidr                = var.cidr
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

  key_name              = var.key_name
  resource_prefix       = var.resource_prefix
  tags                  = var.tags
  staging_instance_type = var.staging_instance_type
  staging_subnet_id     = module.network.public_subnets[0]
  staging_ami           = var.staging_ami
  sg_id                 = module.network.web_sg_id

  user_data = <<-EOF
              #!/bin/bash
              /opt/consul/bin/run-consul --client --cluster-tag-key consul-servers --cluster-tag-value auto-join

              mkdir /home/ubuntu/iot_certs
              wget https://www.amazontrust.com/repository/AmazonRootCA1.pem -O /home/ubuntu/iot_certs/AmazonRootCA1.pem

              cat <<EOT >> /home/ubuntu/iot_certs/device.crt
              ${module.iot.iot_certificate}
              EOT
              cat <<EOT >> /home/ubuntu/iot_certs/private.key
              ${module.iot.iot_private_key}
              EOT
              cat <<EOT >> /home/ubuntu/iot_certs/public.key
              ${module.iot.iot_public_key}
              EOT

              cat <<EOT >> /home/ubuntu/config.yaml
              TSDB_HOST: master.tsdb.service.consul
              TSDB_USER: postgres
              TSDB_PASS: ${random_password.tsdb_postgres.result}
              TSDB_DATABASE: sgmp
              DATABASE_URL: mysql://sgmp:${random_password.rds.result}@${module.rds.dns}/sgmp
              IOT_CERT_ID: ${module.iot.iot_certificate_id}
              IOT_ENDPOINT: ${module.iot.iot_endpoint}
              IOT_CERT_PATH: /home/ubuntu/iot_certs/device.crt
              IOT_KEY_PATH: /home/ubuntu/iot_certs/private.key
              IOT_ROOT_PATH: /home/ubuntu/iot_certs/AmazonRootCA1.pem
              AWS_REGION: ${var.region}
              COGNITO_USER_POOL_ID: us-west-1_opTsFEaul
              COGNITO_APP_CLIENT_ID: 225gul2k0qlq0vjh81cd3va4h
              ENFORCE_AUTHENTICATION: 0
              EOT

              chown -R ubuntu:ubuntu /home/ubuntu

              EOF
}

output "bastion_ip" {
  value = module.bastion.bastion_ip
}

output "staging_ip" {
  value = module.web.staging_ip
}