# AWS ALB

````hcl
provider "aws" {
  region = "us-west-2"
}

# Create a Security Group for ALB
resource "aws_security_group" "TF_ALB_SG" {
  name        = "alb-sg"
  description = "Security group for ALB"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create Security Group for EC2 Instances
resource "aws_security_group" "TF_EC2_SG" {
  name        = "ec2-sg"
  description = "Security group for EC2 instances"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.TF_ALB_SG.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create Target Group
resource "aws_lb_target_group" "TF_TG" {
  name        = "example-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "vpc-xxxxxxxx"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }
}

# Create Load Balancer
resource "aws_lb" "TF_ALB" {
  name               = "example-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.TF_ALB_SG.id]
  subnets            = ["subnet-xxxxxxxx", "subnet-yyyyyyyy"]

  enable_deletion_protection = false
}

# Create Listener
resource "aws_lb_listener" "TF_ALB_LISTENER" {
  load_balancer_arn = aws_lb.TF_ALB.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TF_TG.arn
  }


  # Launch EC2 Instances as Targets
  resource "aws_instance" "example" {
    ami           = "ami-xxxxxxxx" # Replace with a valid AMI
    instance_type = "t2.micro"
    security_groups = [aws_security_group.TF_EC2_SG.name]
    count         = 2 # Two instances

    user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World from $(hostname)!" > /var/www/html/index.html
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              EOF

    tags = {
      Name = "ExampleInstance"
    }
  }

  # Register Targets
  resource "aws_lb_target_group_attachment" "example_attachment" {
    count            = 2
    target_group_arn = aws_lb_target_group.TF_TG.arn
    target_id        = aws_instance.example[count.index].id
    port             = 80
  }

````