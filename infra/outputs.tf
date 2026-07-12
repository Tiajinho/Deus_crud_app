output "service_url" {
  description = "Public base URL of the deployed service."
  value       = "http://${aws_lb.main.dns_name}"
}

output "health_url" {
  description = "Health-check URL (should return 200 OK)."
  value       = "http://${aws_lb.main.dns_name}${var.health_check_path}"
}

output "ecr_repository_url" {
  description = "ECR repository URL for the application image."
  value       = aws_ecr_repository.app.repository_url
}

output "codestar_connection_arn" {
  description = "Authorize this connection once: AWS console > Developer Tools > Settings > Connections > Update pending connection."
  value       = aws_codestarconnections_connection.github.arn
}

output "codepipeline_name" {
  description = "Name of the deployment pipeline."
  value       = aws_codepipeline.main.name
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  value = aws_ecs_service.app.name
}

output "artifacts_bucket" {
  value = aws_s3_bucket.artifacts.bucket
}
