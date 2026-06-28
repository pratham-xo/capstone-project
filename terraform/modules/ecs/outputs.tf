output "ecs_cluster_name" {
  value = aws_ecs_cluster.ecs_cluster.name
}

output "ecs_sg" {
  value = aws_security_group.ecs_sg.id
}

output "ecs_service_name" {
  value = aws_ecs_service.ecs_service.name

}