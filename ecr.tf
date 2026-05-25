# Amazon ECR Repository
# This repository stores the Docker images built by the CI workflow.

resource "aws_ecr_repository" "nginx_repo" {
  name                 = "nginx-docker-repo"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "NginxDockerRepo"
  }
}
