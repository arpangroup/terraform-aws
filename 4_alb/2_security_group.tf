# Security Group for ALB
resource "aws_security_group" "TF_ALB_SG" {
  name        = "alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.TF_VPC.id

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


# Security Group for EC2 Instances
resource "aws_security_group" "TF_EC2_SG" {
  name        = "ec2-sg"
  description = "Security group for EC2 instances"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.TF_ALB_SG.id] # Allow traffic only from the ALB
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}