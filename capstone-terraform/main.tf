module "vpc" {
  source = "./modules/vpc"

  cidr_block           = var.cidr_block
  public_subnet1_cidr  = var.public_subnet1_cidr
  public_subnet2_cidr  = var.public_subnet2_cidr
  private_subnet1_cidr = var.private_subnet1_cidr
  private_subnet2_cidr = var.private_subnet2_cidr
  db_subnet1_cidr      = var.db_subnet1_cidr
  db_subnet2_cidr      = var.db_subnet2_cidr
}

module "alb" {
  source = "./modules/alb"

  vpc_id = module.vpc.vpc_id

  public_sub_ids = [
    module.vpc.aws_public_subnet1,
    module.vpc.aws_public_subnet2
  ]
}

module "ecs" {
  source = "./modules/ecs"

  vpc_id = module.vpc.vpc_id

  private_subnet  = module.vpc.aws_private_subnet1
  private_subnet2 = module.vpc.aws_private_subnet2

  target_group_arn   = module.alb.ecs_target_group_arn
  alb_security_group = module.alb.alb_sg_name
}

module "ecr" {
  source = "./modules/ecr"
}

module "codedeploy" {
  source = "./modules/codedeploy"

  ecs_cluster_name      = module.ecs.ecs_cluster_name
  ecs_service_name      = module.ecs.ecs_service_name
  listener_arn          = module.alb.listener_arn
  blue_target_group_name = "ecs-target-group"
  green_target_group_name = "green-target-group"
}

