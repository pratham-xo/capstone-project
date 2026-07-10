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

  ecs_cluster_name = module.ecs.ecs_cluster_name
  ecs_service_name = module.ecs.ecs_service_name
  ecs_service_arn = module.ecs.ecs_service_arn
  task_definition_arn = module.ecs.task_definition_arn
  listener_arn    = module.alb.listener_arn
  test_listener_arn =  module.alb.test_listener_arn
  blue_target_group_name  = "ecs-target-group"
  green_target_group_name = "green-target-group"
  cloudwatch_alarm = module.cloudwatch.alarm_name
  s3_bucket_arn = module.codepipeline.s3_bucket_arn
}

module "codebuild" {
  source = "./modules/codebuild"

  ecr_repository_url  = module.ecr.ecr_repository_url
  ecr_repository_name = module.ecr.ecr_repository_name
  github_repo_url     = "https://github.com/pratham-xo/capstone-project.git"
  SONAR_HOST_URL = var.SONAR_HOST_URL
}

module "codepipeline" {

  source = "./modules/codepipeline"

  connection_arn = "arn:aws:codeconnections:ap-south-1:723951822972:connection/91267830-9409-4ced-bd37-1b27d34c3a39"

  repository_owner = "pratham-xo"
  repository_name  = "capstone-project"
  branch_name      = "main"

  codebuild_project_name = module.codebuild.codebuild_project_name
  codedeploy_app_name = module.codedeploy.codedeploy_app_name
  codedeploy_deployment_group_name = module.codedeploy.deployment_group_name
  codedeploy_arn = module.codedeploy.codedeploy_arn 
  codebuild_arn = module.codebuild.codebuild_arn
  codedeploy_deployment_group_arn = module.codedeploy.codedeploy_deployment_group_arn
  codedeploy_app_arn = module.codedeploy.codedeploy_arn
  ecs_task_execution_role_arn = module.ecs.task_execution_arn
}

module "sonarqube" {
  source = "./modules/ec2-sonarcube"

  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.aws_public_subnet1
  key_name         = var.key_name
  my_ip = var.my_ip
}

module "ssm" {
  source = "./modules/ssm_parameter_store"
  sonarqube_token = var.sonarqube_token
}

module "cloudwatch" {
  source = "./modules/cloudwatch"
  ALB_arn_suffix = module.alb.alb_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix
  cluster_name = module.ecs.ecs_cluster_name
  service_name = module.ecs.ecs_service_name
  green_target_group_arn_suffix = module.alb.green_target_group_arn_suffix
}