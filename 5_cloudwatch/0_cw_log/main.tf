# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "TF_LOG_GROUP" {
  name              = "/tf-example/log-group"
  retention_in_days = 1 # how long log data is retained in the group before being automatically deleted.

  tags = {
    Environment = "Dev"
  }
}

# EC2 Instance
resource "aws_instance" "TF_WEB_APP" {
  ami           ="ami-0453ec754f44f9a4a"
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.TF_ec2_instance_profile.name
  vpc_security_group_ids      = [var.vpc.public_subnets[0].id]
  key_name                    = var.key_pair

/*  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y amazon-cloudwatch-agent
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
      -a start \
      -m ec2 \
      -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
  EOF*/

  user_data = file("setup_cloudwatch_agent.sh")

  tags = {
    Name = "tf-webapp"
  }
}


# Outputs
output "instance_id" {
  value = aws_instance.TF_WEB_APP.public_ip
}



