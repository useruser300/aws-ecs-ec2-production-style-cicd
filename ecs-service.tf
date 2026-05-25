resource "aws_ecs_service" "nginx_service" {
  name            = "nginx-ecs-service"
  cluster         = aws_ecs_cluster.main_cluster.id
  task_definition = aws_ecs_task_definition.nginx_task.arn

  desired_count = 0

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
    weight            = 1
  }

  network_configuration {
    subnets = [
      aws_subnet.private_subnet_1.id,
      aws_subnet.private_subnet_2.id
    ]

    security_groups = [
      aws_security_group.ecs_task_sg.id
    ]

    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "nginx-container"
    container_port   = 80
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  depends_on = [
    aws_lb_listener.http_listener,
    aws_ecs_cluster_capacity_providers.main_cluster_capacity_providers
  ]

  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition
    ]
  }

  tags = {
    Name = "nginx-ecs-service"
  }
}
