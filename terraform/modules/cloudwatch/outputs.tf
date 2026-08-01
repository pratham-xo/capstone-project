output "alarm_name" {
    value = aws_cloudwatch_metric_alarm.alb_5xx.alarm_name
}

output "unhealthy_host_count_alarm_name" {
    value = aws_cloudwatch_metric_alarm.unhealthy_hosts.alarm_name
}