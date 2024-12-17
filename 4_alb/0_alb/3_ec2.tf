# Launch EC2 Instances as Targets
resource "aws_instance" "webapp" {
  count           = 2
  ami             = "ami-0453ec754f44f9a4a"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.TF_PUBLIC_SUBNET[count.index].id
  security_groups = [aws_security_group.TF_EC2_SG.id]

  user_data = <<-EOF
              #!/bin/bash
              set -e  # Exit script on any error
              yum update -y
              yum install -y httpd

              # Welcome message including Instance Metadata
              echo "<h1>Welcome to Instance ${count.index}</h1><p>Host: $(hostname)</p>" > /var/www/html/index.html
              echo "<p>VPC ID: ${var.vpc_id}</p>" >> /var/www/html/index.html

              systemctl start httpd
              systemctl enable httpd
              EOF

  metadata_options {
    http_tokens = "optional"   # allows both IMDSv1 and IMDSv2.
    http_endpoint = "enabled"  #["enabled", "disabled"] enables the metadata service.
  }

  tags = {
    Name = "ExampleInstance-${count.index}"
  }
}
