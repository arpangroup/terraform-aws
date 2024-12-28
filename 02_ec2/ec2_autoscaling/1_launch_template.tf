# Launch Template
resource "aws_launch_template" "TF_LAUNCH_TEMPLATE" {
  name          = "tf-launch-template"
  image_id      = var.ami
  instance_type = "t2.micro"
  key_name      = var.key_name


  network_interfaces {
    security_groups             = [var.vpc.security_group.id]
    associate_public_ip_address = true
  }

  # user_data = filebase64("${path.module}/ec2-init.sh")
  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd

    echo "<h1>Host: $(hostname)</h1>" > /var/www/html/index.html

    #instance_ip=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
    #echo "Hello from instance IP: $instance_ip" >> /var/www/html/index.html

    systemctl start httpd
    systemctl enable httpd
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name  = "tf-asg-web-server"
    }
  }
}