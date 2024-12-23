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
  ami           ="ami-01816d07b1128cd2d"
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.TF_ec2_instance_profile.name
  subnet_id                   = var.vpc.public_subnets[0].id
  vpc_security_group_ids      = [var.vpc.security_group.id]
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

#   user_data = file("setup_cloudwatch_agent.sh")
  user_data = <<-EOF
            #!/bin/bash
            set -e  # Exit immediately on error

            # Set the HOME environment variable explicitly
            export HOME=/home/ec2-user

            # Logging commands for debugging
            echo "Starting EC2 setup..." > $HOME/setup.log
            sudo yum update -y >> $HOME/setup.log 2>&1

            # Call the Java installation script
            echo "Running Java installation script..." >> $HOME/setup.log
            chmod +x /scripts/install_java.sh  # Make mvnw script executable
            #$(cat ./scripts/install_java.sh) >> $HOME/setup.log 2>&1
            $(file("/scripts/install_java.sh")) >> $HOME/setup.log 2>&1

#             # Install Git
#             echo "Installing Git..." >> $HOME/setup.log
#             sudo yum install -y git >> $HOME/setup.log 2>&1
#
#             # Clone the repository
#             echo "Cloning repository..." >> $HOME/setup.log
#             git clone ${var.github_repo_url} $HOME/hello-ecs-app >> $HOME/setup.log 2>&1
#
#             # Change to the project directory
#             cd $HOME/hello-ecs-app
#             echo "Making mvnw executable..." >> $HOME/setup.log
#             chmod +x ./mvnw  # Make mvnw script executable
#
#             # Running Maven package
#             echo "Running Maven package..." >> $HOME/setup.log
#             ./mvnw package >> $HOME/setup.log 2>&1
#
#             # Run the Spring Boot application
#             echo "Starting the Spring Boot app..." >> $HOME/setup.log
#             nohup java -Dlogging.file.name=$HOME/api.log -jar target/*.jar & >> $HOME/setup.log 2>&1
#             #nohup java -jar target/*.jar &  >> $HOME/setup.log 2>&1
#
#             echo "EC2 setup completed." >> $HOME/setup.log
#
#             # Call the cloudwatch_agent installation script
#             echo "Running Cloudwatch installation script..." >> $HOME/setup.log
#             #chmod +x ./scripts/setup_cloudwatch_agent.sh  # Make script executable
#             #$(cat ./scripts/setup_cloudwatch_agent.sh) >> $HOME/setup.log 2>&1
#             $(file("./scripts/setup_cloudwatch_agent.sh")) >> $HOME/setup.log 2>&1

  EOF

  tags = {
    Name = "tf-webapp"
  }
}


# Outputs
output "instance_id" {
  value = aws_instance.TF_WEB_APP.public_ip
}



