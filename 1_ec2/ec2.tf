resource "aws_instance" "web_app" {
  ami                    = var.instance_ami_t2_micro
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.TF_SG.id]
  key_name               = aws_key_pair.TF_KEY_PAIR.key_name
  #user_data              = file("userdata.sh")
  user_data              = <<-EOF
                          #!/bin/bash
                          set -e  # Exit script on any error
                          yum update -y
                          yum install -y httpd
                          echo "Hello, World!" > /var/www/html/index.html
                          systemctl start httpd
                          systemctl enable httpd
                          EOF


  tags = {
    Name = "WebApp"
  }
}