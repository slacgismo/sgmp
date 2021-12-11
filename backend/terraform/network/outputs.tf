output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "lambda_sg_id" {
  value = aws_security_group.lambda.id
}

output "tsdb_sg_id" {
  value = aws_security_group.tsdb.id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion.id
}

output "web_sg_id" {
  value = aws_security_group.web.id
}

output "rds_sg_id" {
  value = aws_security_group.rds.id
}

output "consul_sg_id" {
  value = aws_security_group.consul.id
}