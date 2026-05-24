# AWS ECS on EC2 Architecture Upgrade

This project represents an upgraded AWS ECS on EC2 deployment architecture based on the previous [aws-ecs-on-ec2-cicd](https://github.com/useruser300/aws-ecs-on-ec2-cicd) project.

The main improvement is moving from a simple public-subnet ECS design to a more production-style design using:

- Private Subnets
- NAT Gateway
- `awsvpc` network mode
- IP-based Target Group
- ECS Tasks with private IPs

## Architecture Diagram

![AWS ECS on EC2 Architecture](images/aws-ecs-ec2-alb-private-subnets-architecture.png)
