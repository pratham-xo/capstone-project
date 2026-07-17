variable "ecs_cluster_name" {}

variable "ecs_service_name" {}

variable "listener_arn" {}

variable "test_listener_arn" {}
  
variable "blue_target_group_name" {}

variable "green_target_group_name" {}

variable "cloudwatch_alarm" {}

variable "ecs_service_arn" {}

variable "task_definition_arn" {}

variable "s3_bucket_arn" {}

variable "alb_arn_suffix" {
  
}

variable "blue_target_group" {
  
}
