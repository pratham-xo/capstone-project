output "ecs_cluster_name" {
  value = aws_ecs_cluster.ecs_cluster.name
}

output "ecs_cluster_id" {
  value = aws_ecs_cluster.ecs_cluster.id
}

output "task_execution_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "task_execution_policy_arn" {
  value = aws_iam_role_policy_attachment.ecs_task_execution_policy.id
}

output "ecs_sg" {
  value = aws_security_group.ecs_sg.id
}