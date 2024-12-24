# EC2 Instance
resource "aws_instance" "TF_WEB_APP" {
  ami           = "ami-01816d07b1128cd2d"  # Replace with your AMI ID
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.TF_CLOUDWATCH_INSTANCE_PROFILE.name
  subnet_id                   = var.vpc.public_subnets[0].id
  vpc_security_group_ids      = [var.vpc.security_group.id]
  key_name                    = var.key_pair

  user_data = <<-EOF
    #!/bin/bash
    set -e  # Exit immediately on error
    echo "Starting EC2 setup..." > /home/ec2-user/setup.log
    curl -sSL https://raw.githubusercontent.com/arpangroup/config-infra/branch_scripts/userdata/userdata_java_spring_cloudwatch.sh | bash >> /home/ec2-user/setup.log 2>&1
  EOF
}


output "instance_id" {
  value = aws_instance.TF_WEB_APP.public_ip
}