module "network" {
  source = "./network"

  region = var.region
  resource_prefix = var.resource_prefix
  tags = var.tags

  cidr = var.cidr
  availability_zones = var.availability_zones
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
}

module "bastion" {
  source = "./bastion"
  depends_on = [module.network]

  key_name = var.key_name
  resource_prefix = var.resource_prefix
  tags = var.tags
  instance_type = var.bastion_instance_type
  subnet_id = module.network.public_subnets[0]
  sg_id = module.network.bastion_sg_id
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

module "consul" {
  source = "./consul"

  region = var.region
  resource_prefix = var.resource_prefix
  tags = var.tags
  ami_id = var.consul_ami
  sg_id = module.network.consul_sg_id
  instance_type = var.consul_instance_type
  key_name = var.key_name
  subnet_ids = module.network.public_subnets
  user_data = <<-EOF
              #!/bin/bash
              export AWS_ACCESS_KEY_ID="${var.aws_access_key_id}"
              export AWS_SECRET_ACCESS_KEY="${var.aws_secret_access_key}"
              mkdir /home/consul/.aws
              cat <<EOT >> /home/consul/.aws/credentials
              [default]
              aws_access_key_id = ${var.aws_access_key_id}
              aws_secret_access_key = ${var.aws_secret_access_key}
              EOT
              chown -R consul:consul /home/consul/.aws
              chmod 600 /home/consul/.aws/credentials
              /opt/consul/bin/run-consul --server --cluster-tag-key consul-servers --cluster-tag-value auto-join
              EOF
}

module "tsdb" {
  source = "./tsdb"

  region = var.region
  resource_prefix = var.resource_prefix
  tags = var.tags

  tsdb_ami = var.tsdb_ami
  tsdb_instance_type = var.tsdb_instance_type
  sg_id = module.network.tsdb_sg_id
  key_name = var.key_name
  subnet_ids = module.network.public_subnets
  user_data = templatefile("tsdb_provision.sh", {
    aws_access_key_id = var.aws_access_key_id,
    aws_secret_access_key = var.aws_secret_access_key,
    replicator_password = random_password.tsdb_replicator.result,
    postgres_password = random_password.tsdb_postgres.result,
    rewind_password = random_password.tsdb_rewind_user.result,
    cidr = var.cidr
  })
  volume_size = var.tsdb_volume_size
  cluster_size = var.tsdb_cluster_size
}

module "rds" {
  source = "./rds"

  region = var.region
  resource_prefix = var.resource_prefix
  tags = var.tags

  instance_type = var.rds_instance_type
  sg_id = module.network.rds_sg_id
  subnet_ids = module.network.private_subnets
  engine_version = var.rds_engine_version
  major_engine_version = var.rds_major_engine_version
  allocated_storage = var.rds_allocated_storage
  password = random_password.rds.result
  delete_protection = var.rds_delete_protection
  multi_az = var.rds_multi_az
}

output "bastion_ip" {
  value = module.bastion.bastion_ip
}