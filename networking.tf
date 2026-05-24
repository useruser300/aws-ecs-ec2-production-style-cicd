# Availability Zones

data "aws_availability_zones" "available" {
  state = "available"
}

# VPC

resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "ecs-main-vpc"
  }
}

# Internet Gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "ecs-main-igw"
  }
}

# Public Subnet 1

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "ecs-public-subnet-1"
  }
}

# Public Subnet 2

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "ecs-public-subnet-2"
  }
}

# Public Route Table

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "ecs-public-route-table"
  }
}

# Route Table Association - Subnet 1

resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

# Route Table Association - Subnet 2

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}



# Private Subnet 1

resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.11.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "ecs-private-subnet-1"
  }
}

# Private Subnet 2

resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.12.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "ecs-private-subnet-2"
  }
}

# Elastic IP for NAT Gateway

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "ecs-nat-eip"
  }
}

# NAT Gateway
# The NAT Gateway is placed in a public subnet.

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id

  depends_on = [
    aws_internet_gateway.igw
  ]

  tags = {
    Name = "ecs-nat-gateway"
  }
}

# Private Route Table
# Private subnets use the NAT Gateway for outbound internet access.

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "ecs-private-route-table"
  }
}

# Private Route Table Association - Subnet 1

resource "aws_route_table_association" "private_assoc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

# Private Route Table Association - Subnet 2

resource "aws_route_table_association" "private_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}






# ALB Security Group

resource "aws_security_group" "alb_sg" {
  name        = "ecs-alb-sg"
  description = "Allow HTTP traffic from the internet to the Application Load Balancer"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "Allow HTTP from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-alb-sg"
  }
}





# ECS EC2 Security Group


resource "aws_security_group" "ecs_ec2_sg" {
  name        = "ecs-ec2-sg"
  description = "Allow traffic from ALB to ECS container instances"
  vpc_id      = aws_vpc.main_vpc.id

  #  ingress {
  #    description     = "Allow application traffic from ALB"
  #    from_port       = 32768
  #    to_port         = 65535
  #    protocol        = "tcp"
  #    security_groups = [aws_security_group.alb_sg.id]
  #  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-ec2-sg"
  }
}




# ECS Task Security Group
# This security group is attached directly to ECS tasks when using awsvpc mode.
# It allows HTTP traffic only from the ALB security group.

resource "aws_security_group" "ecs_task_sg" {
  name        = "ecs-task-sg"
  description = "Allow HTTP traffic from ALB to ECS tasks"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description     = "Allow HTTP from ALB to ECS tasks"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-task-sg"
  }
}

