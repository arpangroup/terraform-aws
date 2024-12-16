# Launch EC2 Instances as Targets
resource "aws_instance" "example" {
  ami           = "ami-0453ec754f44f9a4a"
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