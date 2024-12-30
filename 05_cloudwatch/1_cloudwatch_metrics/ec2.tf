provider "aws" {
  region = "us-east-1"
}

# EC2 Instance
resource "aws_instance" "TF_WEB_APP" {
  ami           = "ami-01816d07b1128cd2d"
  instance_type = "t2.micro"
#   iam_instance_profile = aws_iam_instance_profile.TF_CLOUDWATCH_INSTANCE_PROFILE.name
  subnet_id                   = var.vpc.public_subnets[0].id
  vpc_security_group_ids      = [var.vpc.security_group.id]
  key_name                    = var.key_pair

  user_data = <<-EOF
    #!/bin/bash
    set -e  # Exit immediately on error
    echo "Starting EC2 setup..." > /home/ec2-user/setup.log
    yum update -y
    yum install -y httpd

    # Welcome message including Instance Metadata
    echo "<h1>Welcome to </h1><p>Host: $(hostname)</p>" > /var/www/html/index.html

    systemctl start httpd
    systemctl enable httpd
  EOF
}


output "instance_id" {
  value = aws_instance.TF_WEB_APP.public_ip
}