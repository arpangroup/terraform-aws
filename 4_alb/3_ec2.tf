# Launch EC2 Instances as Targets
resource "aws_instance" "webapp" {
  count           = 2
  ami             = "ami-0453ec754f44f9a4a"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.TF_PUBLIC_SUBNET[count.index].id
  security_groups = [aws_security_group.TF_EC2_SG.name]

  user_data = <<-EOF
              #!/bin/bash
              echo "<h1>Welcome to Instance ${count.index} - Host: $(hostname)</h1>" > /var/www/html/index.html
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              EOF

  tags = {
    Name = "ExampleInstance-${count.index}"
  }
}
