resource "aws_iam_role" "codedeploy_role" {
  name = "codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role_policy" "codedeploy_ecs_policy" {
  name = "codedeploy-ecs-policy"
  role = aws_iam_role.codedeploy_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:CreateTaskSet",
          "ecs:UpdateServicePrimaryTaskSet",
          "ecs:DeleteTaskSet"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "elasticloadbalancing:*"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "lambda:InvokeFunction",
          "cloudwatch:DescribeAlarms",
          "sns:Publish",
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_role_policy" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_codedeploy_app" "ecs_app" {
  name = "starbucks-ecs-app"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "ecs_deployment_group" {
  app_name = aws_codedeploy_app.ecs_app.name
  deployment_group_name = "starbucks-ecs-deployment-group"
  
  service_role_arn = aws_iam_role.codedeploy_role.arn
  
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
   
   deployment_style {
     deployment_type = "BLUE_GREEN"
     deployment_option = "WITH_TRAFFIC_CONTROL"
   }

   ecs_service{
    cluster_name = var.ecs_cluster_name
    service_name = var.ecs_service_name
   }

   blue_green_deployment_config {
     deployment_ready_option {
       action_on_timeout = "CONTINUE_DEPLOYMENT"
     }
      terminate_blue_instances_on_deployment_success {
     action = "TERMINATE"
     termination_wait_time_in_minutes = 5
   }
   }

   load_balancer_info {
     target_group_pair_info {
       prod_traffic_route {
         listener_arns = [var.listener_arn]
       }
       target_group {
            name = var.blue_target_group_name
       }
       target_group {
            name = var.green_target_group_name
       }
     }
   }

}