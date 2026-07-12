#!/usr/bin/env bash
# Build and push an initial image so the ECS service has something to run before
# the first pipeline execution. Run once, after `terraform apply`.
#
# Usage: AWS_REGION=us-east-1 ./scripts/bootstrap_image.sh
set -euo pipefail

AWS_REGION="${AWS_REGION:-us-east-1}"
REPO_URL="$(terraform -chdir=infra output -raw ecr_repository_url)"
REGISTRY="${REPO_URL%%/*}"

echo "Logging in to ECR: $REGISTRY"
aws ecr get-login-password --region "$AWS_REGION" \
  | docker login --username AWS --password-stdin "$REGISTRY"

# Force linux/amd64 so images built on Apple Silicon run on X86_64 Fargate.
echo "Building and pushing $REPO_URL:latest"
docker build --platform linux/amd64 -t "$REPO_URL:latest" .
docker push "$REPO_URL:latest"

echo "Done. You can now trigger the pipeline (push to the tracked branch)."
