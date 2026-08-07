resource "aws_s3_bucket" "pipeline_bucket" {
  bucket = "capstone-pipeline-artifacts-${random_string.suffix.result}"
   force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "artifact_bucket_public_access_block" {
  bucket = aws_s3_bucket.pipeline_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "pipeline_bucket" {
  bucket = aws_s3_bucket.pipeline_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "pipeline_bucket" {
  bucket = aws_s3_bucket.pipeline_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "https_only" {
  bucket = aws_s3_bucket.pipeline_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"

        Action = "s3:*"

        Resource = [
          aws_s3_bucket.pipeline_bucket.arn,
          "${aws_s3_bucket.pipeline_bucket.arn}/*"
        ]

        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
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
    },
    ]
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
  "s3:GetObject",
  "s3:GetObjectVersion",
  "s3:PutObject",
  "s3:GetBucketVersioning"
        ]

        Resource = [
          aws_s3_bucket.pipeline_bucket.arn,
          "${aws_s3_bucket.pipeline_bucket.arn}/*"
        ]
      },

      {
        Effect = "Allow"

        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ]

        Resource = var.codebuild_arn
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
    "codedeploy:GetApplicationRevision",
    "codedeploy:GetDeployment",
    "codedeploy:GetDeploymentGroup",
    "codedeploy:GetDeploymentConfig",
    "codedeploy:RegisterApplicationRevision",
    "codedeploy:ListDeployments",
    "codedeploy:StopDeployment"
  ]

  Resource = "*"
},
{
  Effect = "Allow"

  Action = [
    "ecs:RegisterTaskDefinition",
    "ecs:DescribeTaskDefinition",
    "ecs:DescribeServices",
    "ecs:DescribeTaskSets",
    "ecs:DescribeClusters"
  ]

  Resource = "*"
},
{
  Effect = "Allow"

  Action = [
    "iam:PassRole"
  ]

  Resource = var.ecs_task_execution_role_arn
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
    provider = "CodeBuild"
    version  = "1"

    input_artifacts = ["build_output"]

    configuration = {
      ProjectName = var.codebuild_project_name
    }
  }
}
}