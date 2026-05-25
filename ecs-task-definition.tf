# ECS Task Definition
# This task definition describes how ECS should run the Nginx container.

resource "aws_ecs_task_definition" "nginx_task" {
  family                   = "nginx-ecs-task"
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  cpu    = 256
  memory = 256

  container_definitions = jsonencode([
    {
      name      = "nginx-container"
      image     = "${aws_ecr_repository.nginx_repo.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_log_group.name
          awslogs-region        = "eu-central-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "nginx-ecs-task-definition"
  }
}
