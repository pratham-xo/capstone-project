variable "name_prefix" {
  type = string
}

variable "ecs_cluster_id" {
  type = string
}

variable "image_uri" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "ecs_sg_id" {
  type = string
}

variable "container_port" {
  type    = number
  default = 80
}
