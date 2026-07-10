output "ecs_cluster_name" {
  value = aws_ecs_cluster.ecs_cluster.name
}

output "ecs_sg" {
  value = aws_security_group.ecs_sg.id
}

output "ecs_service_name" {
  value = aws_ecs_service.ecs_service.name
}

output "ecs_service_arn" {
  value = aws_ecs_service.ecs_service.id
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.ecs_task.arn
}

output "task_execution_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}