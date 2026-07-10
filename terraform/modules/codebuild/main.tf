resource "aws_iam_role" "codebuild_role" {
  name = "capstone-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "codebuild.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_policy" "codebuild_policy" {

  name = "capstone-codebuild-policy"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "ecr:BatchGetImage"
        ]

        Resource = "arn:aws:ecr:ap-south-1:723951822972:repository/capstone-ecr"
      },

      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "arn:aws:logs:ap-south-1:723951822972:log-group:/aws/codebuild/capstone-build:*"
      },
      {
  Effect = "Allow"

  Action = [
    "s3:GetObject",
    "s3:GetObjectVersion",
    "s3:GetBucketLocation",
    "s3:PutObject"
  ]

  Resource = [
    "arn:aws:s3:::capstone-pipeline-artifacts-*",
    "arn:aws:s3:::capstone-pipeline-artifacts-*/*"
  ]
},
{
  Effect = "Allow"

  Action = [
    "ssm:GetParameter",
  ]

  Resource = "arn:aws:ssm:ap-south-1:723951822972:parameter/sonarqube/token"
}
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_role_policy_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}

resource "aws_cloudwatch_log_group" "codebuild" {
  name              = "/aws/codebuild/capstone-build"
  retention_in_days = 30
}

resource "aws_codebuild_project" "capstone_build" {
  name         = "capstone-build"
  service_role = aws_iam_role.codebuild_role.arn
  
  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type     = "CODEPIPELINE"
    buildspec = "buildspec.yaml"
  }

  environment {

    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    privileged_mode = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = "ap-south-1"
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = var.ecr_repository_name
    }

    environment_variable {
      name  = "REPOSITORY_URI"
      value = var.ecr_repository_url
    }
    environment_variable {
  name  = "SONAR_HOST_URL"
  value = var.SONAR_HOST_URL
}
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }
}

