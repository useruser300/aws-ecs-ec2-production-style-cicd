# ECR Outputs

output "ecr_repository_url" {
  description = "The URL of the Amazon ECR repository"
  value       = aws_ecr_repository.nginx_repo.repository_url
}

output "ecr_repository_name" {
  description = "The name of the Amazon ECR repository"
  value       = aws_ecr_repository.nginx_repo.name
}

# ECS Outputs

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.main_cluster.name
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.nginx_service.name
}

output "ecs_task_definition_family" {
  description = "The ECS task definition family name"
  value       = aws_ecs_task_definition.nginx_task.family
}

output "ecs_task_definition_arn" {
  description = "The ARN of the ECS task definition"
  value       = aws_ecs_task_definition.nginx_task.arn
}

output "container_name" {
  description = "The name of the container inside the ECS task definition"
  value       = "nginx-container"
}

# Load Balancer Outputs

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.app_alb.dns_name
}

output "application_url" {
  description = "The public URL of the application"
  value       = "http://${aws_lb.app_alb.dns_name}"
}
