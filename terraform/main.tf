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

module "alb_blue" {
  source = "./modules/alb"

  vpc_id = module.vpc.vpc_id
  name_prefix = "blue"
  public_sub_ids = [
    module.vpc.aws_public_subnet1,
    module.vpc.aws_public_subnet2
  ]
}

module "alb_green" {
  source = "./modules/alb"
  vpc_id = module.vpc.vpc_id
  name_prefix = "green"
  public_sub_ids = [
    module.vpc.aws_public_subnet1,
    module.vpc.aws_public_subnet2
  ]
}

module "ecs_blue" {
  source              = "./modules/ecs_services"
  name_prefix         = "blue"
  ecs_cluster_id      = module.ecs.ecs_cluster_id
  image_uri           = "723951822972.dkr.ecr.ap-south-1.amazonaws.com/capstone-ecr:v1"
  target_group_arn    = module.alb_blue.ecs_target_group_arn
  execution_role_arn  = module.ecs.task_execution_arn
  private_subnets     = [module.vpc.private_subnet1, module.vpc.private_subnet2]
  ecs_sg_id           = module.ecs.ecs_sg
}

module "ecs_green" {
  source              = "./modules/ecs_services"
  name_prefix         = "green"
  ecs_cluster_id      = module.ecs.ecs_cluster_id
  image_uri           = "723951822972.dkr.ecr.ap-south-1.amazonaws.com/capstone-ecr:v1"
  target_group_arn    = module.alb_green.ecs_target_group_arn
  execution_role_arn  = module.ecs.task_execution_arn
  private_subnets     = [module.vpc.private_subnet1, module.vpc.private_subnet2]
  ecs_sg_id           = module.ecs.ecs_sg
  
}

module "ecs" {
  source = "./modules/ecs"
  vpc_id = module.vpc.vpc_id
  alb_security_groups = [module.alb_blue.alb_sg_name, module.alb_green.alb_sg_name]
}

module "ecr" {
  source = "./modules/ecr"
}

module "codebuild" {
  source = "./modules/codebuild"

  ecr_repository_url  = module.ecr.ecr_repository_url
  ecr_repository_name = module.ecr.ecr_repository_name
  github_repo_url     = "https://github.com/pratham-xo/capstone-project.git"
  SONAR_HOST_URL = var.SONAR_HOST_URL
  hosted_zone_id = var.hosted_zone_id
  ecs_cluster_name = module.ecs.ecs_cluster_name
  record_name = var.record_name
  blue_alb_dns = module.alb_blue.alb_dns_name
  blue_alb_zone_id = module.alb_blue.alb_zone_id
  green_alb_dns = module.alb_green.alb_dns_name 
  green_alb_zone_id = module.alb_green.alb_zone_id
  ecs_task_execution_role_arn = module.ecs.task_execution_arn
}

module "codepipeline" {

  source = "./modules/codepipeline"

  connection_arn = "arn:aws:codeconnections:ap-south-1:723951822972:connection/91267830-9409-4ced-bd37-1b27d34c3a39"

  repository_owner = "pratham-xo"
  repository_name  = "capstone-project"
  branch_name      = "main"
  codebuild_project_name = module.codebuild.codebuild_project_name
  codebuild_arn = module.codebuild.codebuild_arn
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
  ALB_arn_suffix           = module.alb_blue.alb_suffix
  target_group_arn_suffix  = module.alb_blue.target_group_arn_suffix
  cluster_name             = module.ecs.ecs_cluster_name
  service_name             = module.ecs_blue.service_name
  alert_email              = var.alert_email
}


module "route53" {
  source = "./modules/route53"
  domain_name  = var.domain_name
  record_name  = var.record_name
  alb_dns_name = module.alb_blue.alb_dns_name   # blue is initial prod
  alb_zone_id  = module.alb_blue.alb_zone_id
}