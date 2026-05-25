# Application Load Balancer
# The ALB is the public entry point for the application.

resource "aws_lb" "app_alb" {
  name               = "ecs-nginx-alb"
  load_balancer_type = "application"
  internal           = false

  security_groups = [
    aws_security_group.alb_sg.id
  ]

  subnets = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]

  tags = {
    Name = "ecs-nginx-alb"
  }
}




# Target Group
# The ECS service will register its tasks in this target group.

resource "aws_lb_target_group" "app_tg" {
  name        = "ecs-nginx-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main_vpc.id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "ecs-nginx-target-group"
  }
}




# ALB Listener
# The listener receives HTTP traffic on port 80 and forwards it to the target group.

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
