# ECS Cluster
# This cluster will run ECS tasks using the EC2 launch type.

resource "aws_ecs_cluster" "main_cluster" {
  name = "nginx-ecs-cluster"

  tags = {
    Name = "nginx-ecs-cluster"
  }
}



# CloudWatch Log Group
# ECS tasks will send container logs to this log group.

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/aws/ecs/nginx-app"
  retention_in_days = 7

  tags = {
    Name = "nginx-ecs-log-group"
  }
}
