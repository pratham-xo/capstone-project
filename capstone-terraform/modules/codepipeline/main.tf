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
      }
    ]
  })
}

resource "aws_codepipeline" "pipeline" {

  name     = "capstone-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_bucket.bucket
    type     = "S3"
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

      configuration = {
        ProjectName = var.codebuild_project_name
      }
    }
  }
}