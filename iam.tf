# ECS EC2 Instance Role
# This role is attached to the EC2 instances that will join the ECS cluster.

resource "aws_iam_role" "ecs_instance_role" {
  name = "ecs-ec2-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "ecs-ec2-instance-role"
  }
}



# Attach ECS EC2 Managed Policy
# This policy allows EC2 instances to work as ECS container instances.

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}




# EC2 Instance Profile
# The instance profile is required to attach the IAM role to EC2 instances.

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs-ec2-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}






# ECS Task Execution Role
# This role is used by ECS tasks to pull images from ECR and send logs to CloudWatch.

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "ecs-task-execution-role"
  }
}






# Attach ECS Task Execution Managed Policy
# This policy allows ECS tasks to pull images from ECR and write logs to CloudWatch.

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
