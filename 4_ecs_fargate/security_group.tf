
# Create a security group for public access
resource "aws_security_group" "TF_SG" {
  name        = "public_sg"
  description = "Security group for public access"
  vpc_id      = aws_vpc.TF_VPC.id

  #   ingress {
  #     from_port   = 22
  #     to_port     = 22
  #     protocol    = "tcp"
  #     cidr_blocks = ["0.0.0.0/0"] # Allow SSH access from anywhere
  #   }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP access from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}