output "lambda_role_arn" {
  value = aws_iam_role.lambda.arn
}

output "bastion_profile_name" {
  value = aws_iam_instance_profile.bastion.name
}

output "consul_profile_name" {
  value = aws_iam_instance_profile.consul.name
}

output "tsdb_profile_name" {
  value = aws_iam_instance_profile.tsdb.name
}

output "ecs_execution_role_policy_arn" {
  value = aws_iam_policy.ecs_execution.arn
}

output "ecs_task_role_policy_arn" {
  value = aws_iam_policy.web_services.arn
}

output "web_role_arn" {
  value = aws_iam_role.web.arn
}