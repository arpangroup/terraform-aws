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
    security_groups = [aws_security_group.TF_ALB_SG.id]  # Allow traffic only from the ALB
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
resource "aws_lb_listener" "TF_ALB_HTTP_TCP_LISTENER" {
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

## Why load balancer need subnet?
- **Public Subnets:** Used for load balancers that handle traffic from the internet (e.g., ALB/NLB for public-facing web apps).
- **Private Subnets:** Used for internal load balancers that manage traffic within the VPC (e.g., service-to-service communication).
- **High Availability and Redundancy**
  - bLoad balancers are designed to operate across **multiple Availability Zones (AZs)** to ensure fault tolerance and high availability. Subnets allow the load balancer to place its nodes in each AZ.
  - For example:
    - If a load balancer spans three AZs, you must associate it with at least one subnet in each of these AZs.
    - The load balancer automatically creates nodes in each subnet to distribute traffic efficiently.


## What is the use of Listener in LoadBalancer?
A listener in an Application Load Balancer (ALB) is a critical component that defines `how the ALB handles incoming traffic`. It listens for connection requests from clients based on a specific protocol (`HTTP` or `HTTPS`) and `port`, then routes them to one or more target groups based on the rules configured.
- How ALB Listener Works
  1. A **client sends a request** to the ALB.
  2. The ALB **listener evaluates the incoming request**
     - Matches the request's protocol, port, host, or path against its configured rules.
  3. Based on the rules, the listener determines the **target group** or action:
     - Forward the request to a backend target (EC2, ECS, Lambda, etc.).
     - Redirect the request or return a fixed response.
- Why Listeners Are Important?
  - **Traffic Handling:** Listeners determine how the ALB should handle client requests.
  - **Flexibility:** Enables advanced routing capabilities like host/path-based routing and redirects.
  - **Security:** HTTPS listeners handle SSL/TLS termination, ensuring secure communication.
  - **Scalability:** Distributes traffic to appropriate target groups for optimized performance.

## Best Practices:
1. **Use Subnets in Multiple AZs:** This ensures fault tolerance and high availability.
2. **Match Subnets to Traffic Type:**
   - **Public-facing traffic:** Use public subnets with a route to an internet gateway.
   - **Internal traffic:** Use private subnets with restricted network access.
3. **Ensure Sufficient IPs:** Subnets should have enough IP addresses for load balancer nodes, targets, and other resources in that subnet.
