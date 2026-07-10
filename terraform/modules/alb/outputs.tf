output "ecs_target_group_arn" {
  value = aws_lb_target_group.aws_ecs_target_group.arn
}

output "green_target_group_arn" {
  value = aws_lb_target_group.green_target_group.arn
}

output "listener_arn" {
  value = aws_lb_listener.http_listener.arn
}

output "test_listener_arn" {
  value = aws_lb_listener.test_listener.arn
  
}

output "alb_dns_name" {
  value = aws_lb.ALB.dns_name
}

output "alb_sg_name" {
  value = aws_security_group.alb_sg.id
}

output "alb_suffix" {
  value = aws_lb.ALB.arn_suffix
}

output "target_group_arn_suffix" {
  value = aws_lb_target_group.aws_ecs_target_group.arn_suffix
}

output "green_target_group_arn_suffix" {
  value = aws_lb_target_group.green_target_group.arn_suffix
}