# Security Group for ALB
resource "aws_security_group" "TF_ALB_SG" {
  name        = "tf-alb-sg"
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
  name        = "tf-ec2-sg"
  description = "Security group for EC2 instances"
  vpc_id      = aws_vpc.TF_VPC.id

  ingress {
    description     = "Allow traffic only from the ALB "
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    #security_groups = [aws_security_group.TF_ALB_SG.id] # Allow traffic only from the ALB
    cidr_blocks     = ["0.0.0.0/0"] # from anywhere
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH access from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}