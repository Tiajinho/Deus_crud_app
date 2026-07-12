variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name, used to prefix resource names."
  type        = string
  default     = "python-crud-cloud"
}

variable "environment" {
  description = "Environment name (dev/staging/prod)."
  type        = string
  default     = "dev"
}

variable "container_port" {
  description = "Port the container/app listens on."
  type        = number
  default     = 8000
}

variable "container_cpu" {
  description = "Fargate task CPU units (256 = 0.25 vCPU)."
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Fargate task memory (MiB)."
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of ECS tasks to run."
  type        = number
  default     = 1
}

variable "health_check_path" {
  description = "HTTP path used by the ALB target group health check."
  type        = string
  default     = "/health"
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
  default     = 7
}

variable "github_owner" {
  description = "GitHub organization/user that owns the repo."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name."
  type        = string
}

variable "github_branch" {
  description = "Branch that triggers the deployment pipeline."
  type        = string
  default     = "main"
}

variable "github_token" {
  description = "Optional GitHub PAT to enable the CodeBuild pull-request webhook. Leave empty to skip PR validation."
  type        = string
  default     = ""
  sensitive   = true
}
