output "service_name" {
  value = aws_ecs_service.ecs_service.name
}

output "task_definition_family" {
  value = aws_ecs_task_definition.ecs_task.family
}