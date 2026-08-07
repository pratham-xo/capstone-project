variable "vpc_id" {
  type = string
}

variable "alb_security_groups" {
  description = "List of ALB security group IDs allowed to reach ECS tasks"
  type        = list(string)
}