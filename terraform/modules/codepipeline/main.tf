resource "aws_s3_bucket" "pipeline_bucket" {
  bucket = "capstone-pipeline-artifacts-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
    length  = 6
    special = false
    upper = false
}

resource "aws_iam_role" "codepipeline_role" {
  name = "capstone-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "codepipeline.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codepipeline_policy" {

  name = "capstone-codepipeline-policy"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"

        Action = [
          "s3:*"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "codestar-connections:UseConnection"
        ]

        Resource = var.connection_arn
      },
      {
  Effect = "Allow"

  Action = [
    "codedeploy:CreateDeployment",
    "codedeploy:GetApplication",
    "codedeploy:GetDeployment",
    "codedeploy:GetDeploymentGroup",
    "codedeploy:RegisterApplicationRevision"
  ]

  Resource = "*"
}
    ]
  })
}

resource "aws_codepipeline" "pipeline" {

  name     = "capstone-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  pipeline_type = "V2"

  artifact_store {
    location = aws_s3_bucket.pipeline_bucket.bucket
    type     = "S3"
  }

  trigger {

  provider_type = "CodeStarSourceConnection"

  git_configuration {

    source_action_name = "Source"

    push {

      branches {

        includes = ["main"]

      }
    }
  }
}

  stage {

    name = "Source"

    action {

      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"

      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.connection_arn
        FullRepositoryId = "${var.repository_owner}/${var.repository_name}"
        BranchName       = var.branch_name
      }
    }
  }

  stage {

    name = "Build"

    action {

      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"

      input_artifacts  = ["source_output"]
      output_artifacts = [ "build_output" ]

      configuration = {
        ProjectName = var.codebuild_project_name
      }
    }
  }

  stage {

  name = "Deploy"

  action {

    name     = "DeployToECS"
    category = "Deploy"
    owner    = "AWS"
    provider = "CodeDeployToECS"
    version  = "1"

    input_artifacts = ["build_output"]

    configuration = {
      ApplicationName                = var.codedeploy_app_name
      DeploymentGroupName            = var.codedeploy_deployment_group_name

      TaskDefinitionTemplateArtifact = "build_output"
      TaskDefinitionTemplatePath     = "taskdef.json"

      AppSpecTemplateArtifact        = "build_output"
      AppSpecTemplatePath            = "appspec.yaml"

      Image1ArtifactName             = "build_output"
      Image1ContainerName            = "IMAGE1_NAME"
    }
  }
}
}