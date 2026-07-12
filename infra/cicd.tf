locals {
  enable_pr_webhook = var.github_token != ""
}

# ---------------------------------------------------------------------------
# Pipeline artifact bucket
# ---------------------------------------------------------------------------
resource "aws_s3_bucket" "artifacts" {
  bucket        = "${local.name_prefix}-artifacts-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket                  = aws_s3_bucket.artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ---------------------------------------------------------------------------
# GitHub source connection (authorize once in the console after apply)
# ---------------------------------------------------------------------------
resource "aws_codestarconnections_connection" "github" {
  name          = substr("${var.project_name}-gh", 0, 32)
  provider_type = "GitHub"
}

# ---------------------------------------------------------------------------
# CodeBuild: main build (quality gate + image build/push + deploy artifacts)
# ---------------------------------------------------------------------------
resource "aws_codebuild_project" "build" {
  name         = "${local.name_prefix}-build"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true # required to build Docker images

    environment_variable {
      name  = "AWS_REGION"
      value = var.aws_region
    }
    environment_variable {
      name  = "ECR_REPO_URL"
      value = aws_ecr_repository.app.repository_url
    }
    environment_variable {
      name  = "CONTAINER_NAME"
      value = "app"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "ci/buildspec.yml"
  }
}

# ---------------------------------------------------------------------------
# CodeBuild: pull-request quality gate (optional; needs a GitHub token)
# ---------------------------------------------------------------------------
resource "aws_codebuild_source_credential" "github" {
  count       = local.enable_pr_webhook ? 1 : 0
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = var.github_token
}

resource "aws_codebuild_project" "pr" {
  count        = local.enable_pr_webhook ? 1 : 0
  name         = "${local.name_prefix}-pr"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type                = "GITHUB"
    location            = "https://github.com/${var.github_owner}/${var.github_repo}.git"
    buildspec           = "ci/buildspec-test.yml"
    report_build_status = true
  }

  depends_on = [aws_codebuild_source_credential.github]
}

resource "aws_codebuild_webhook" "pr" {
  count        = local.enable_pr_webhook ? 1 : 0
  project_name = aws_codebuild_project.pr[0].name
  build_type   = "BUILD"

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PULL_REQUEST_CREATED,PULL_REQUEST_UPDATED,PULL_REQUEST_REOPENED"
    }
  }
}

# ---------------------------------------------------------------------------
# CodePipeline: Source (GitHub) -> Build -> Deploy (native ECS rolling deploy)
# ---------------------------------------------------------------------------
resource "aws_codepipeline" "main" {
  name     = "${local.name_prefix}-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
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
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = "${var.github_owner}/${var.github_repo}"
        BranchName       = var.github_branch
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
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts = ["build_output"]

      configuration = {
        ClusterName = aws_ecs_cluster.main.name
        ServiceName = aws_ecs_service.app.name
        FileName    = "imagedefinitions.json"
      }
    }
  }
}
