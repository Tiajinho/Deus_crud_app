terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
  }

  # For production, use a remote state backend with locking. Create the bucket +
  # DynamoDB table once (see README "Remote state"), then uncomment:
  #
  # backend "s3" {
  #   bucket         = "REPLACE-ME-tfstate"
  #   key            = "python-crud-cloud/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "REPLACE-ME-tf-lock"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

data "aws_caller_identity" "current" {}
