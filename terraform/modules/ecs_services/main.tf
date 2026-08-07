  resource "aws_ecs_task_definition" "ecs_task" {
    family                   = "capstone-task-${var.name_prefix}"
    requires_compatibilities = ["FARGATE"]

    network_mode = "awsvpc"

    cpu    = "256"
    memory = "512"

    runtime_platform {
      cpu_architecture        = "X86_64"
      operating_system_family = "LINUX"
    }

    execution_role_arn = var.execution_role_arn

    container_definitions = jsonencode([
      {
        name      = "starbucks-container"
        image     = var.image_uri
        essential = true

        portMappings = [
          {
            containerPort = 80
            protocol      = "tcp"
          }
        ]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            "awslogs-group"         = "/ecs/capstone-task-${var.name_prefix}"
            "awslogs-region"        = "ap-south-1"
            "awslogs-stream-prefix" = "ecs"
          }
        }
        
      }
    ])
  }


  resource "aws_ecs_service" "ecs_service" {
    name            = "starbucks-service-${var.name_prefix}"
    cluster         = var.ecs_cluster_id
    task_definition = aws_ecs_task_definition.ecs_task.arn

    desired_count = 1

    launch_type = "FARGATE"

    deployment_controller {
      type = "ECS"
    }
    lifecycle {
    ignore_changes = [
      task_definition,
      load_balancer
    ]
  }

    network_configuration {
      subnets = var.private_subnets

      security_groups = [
    var.ecs_sg_id
  ]

      assign_public_ip = false
    }


    load_balancer {
      target_group_arn = var.target_group_arn
      container_name   = "starbucks-container"
      container_port   = var.container_port
    }

    
  }