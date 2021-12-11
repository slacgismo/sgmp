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

output "ecs_web_execution_role_arn" {
  value = aws_iam_role.ecs_web_execution.arn
}

output "ecs_web_task_role_arn" {
  value = aws_iam_role.ecs_web_task.arn
}
