# ECS-Optimized Amazon Linux 2 AMI
# This AMI includes Docker and the ECS agent.

data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}



# ECS Launch Template
# This template defines how ECS EC2 instances should be created.

resource "aws_launch_template" "ecs_launch_template" {
  name_prefix   = "ecs-nginx-lt-"
  image_id      = data.aws_ssm_parameter.ecs_optimized_ami.value
  instance_type = "t3.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  vpc_security_group_ids = [
    aws_security_group.ecs_ec2_sg.id
  ]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.main_cluster.name} >> /etc/ecs/ecs.config
  EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "ecs-nginx-container-instance"
    }
  }

  tags = {
    Name = "ecs-nginx-launch-template"
  }
}




# ECS Auto Scaling Group
# This ASG provides EC2 capacity for the ECS cluster.

resource "aws_autoscaling_group" "ecs_asg" {
  name             = "ecs-nginx-asg"
  desired_capacity = 1
  min_size         = 1
  max_size         = 2
  vpc_zone_identifier = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]

  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "ecs-nginx-container-instance"
    propagate_at_launch = true
  }
}



# ECS Capacity Provider
# This connects the Auto Scaling Group to ECS.


resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = "nginx-ec2-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_asg.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 100
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 1
    }
  }

  tags = {
    Name = "ecs-nginx-capacity-provider"
  }
}




# Attach Capacity Provider to ECS Cluster
# This tells ECS to use this capacity provider for running tasks.

resource "aws_ecs_cluster_capacity_providers" "main_cluster_capacity_providers" {
  cluster_name = aws_ecs_cluster.main_cluster.name

  capacity_providers = [
    aws_ecs_capacity_provider.ecs_capacity_provider.name
  ]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
    weight            = 1
    base              = 1
  }
}
