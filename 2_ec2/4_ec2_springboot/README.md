## Deploy SpringBoot app from GitHub to an EC2 instance.
````hcl
resource "aws_instance" "springboot_instance" {
  ami           = var.ami
  instance_type = "t2.micro"
  key_name      = var.key_name
  subnet_id     = var.vpc.public_subnets[0].id
  vpc_security_group_ids = [var.vpc.security_group.id]


  user_data = <<-EOF
            #!/bin/bash
            set -e  # Exit immediately on error

            # Set the HOME environment variable explicitly
            export HOME=/home/ec2-user

            # Logging commands for debugging
            echo "Starting EC2 setup..." > $HOME/setup.log
            sudo yum update -y >> $HOME/setup.log 2>&1

            # Install dependencies
            sudo yum install -y java-21-amazon-corretto-headless >> $HOME/setup.log 2>&1
            sudo yum install -y git >> $HOME/setup.log 2>&1

            # Verify Java installation
            java -version >> $HOME/setup.log 2>&1

            # Clone the repository
            echo "Cloning repository..." >> $HOME/setup.log
            git clone ${var.github_repo_url} $HOME/hello-ecs-app >> $HOME/setup.log 2>&1

            # Check if the repository was cloned successfully
            if [ ! -d "$HOME/hello-ecs-app" ]; then
              echo "Failed to clone the repository" >> $HOME/setup.log
              exit 1
            fi

            # Change to the project directory
            cd $HOME/hello-ecs-app
            echo "Making mvnw executable..." >> $HOME/setup.log
            chmod +x ./mvnw  # Make mvnw script executable


            # Running Maven package
            echo "Running Maven package..." >> $HOME/setup.log
            ./mvnw package >> $HOME/setup.log 2>&1

            # Run the Spring Boot application
            echo "Starting the Spring Boot app..." >> $HOME/setup.log
            nohup java -Dlogging.file.name=$HOME/api.log -jar target/*.jar & >> $HOME/setup.log 2>&1
            #nohup java -jar target/*.jar &  >> $HOME/setup.log 2>&1

            echo "EC2 setup completed." >> $HOME/setup.log
  EOF

  tags = {
    Name = "SpringBoot-EC2"
  }
}

output "ec2_public_ip" {
  value = aws_instance.springboot_instance.public_ip
  description = "Public IP address of the EC2 instance"
}
````

# send Spring Boot application logs to CloudWatch
## 1. IAM Role for CloudWatch
````hcl
resource "aws_iam_role" "cloudwatch_role" {
  name = "ec2-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "cloudwatch_policy" {
  name = "ec2-cloudwatch-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "cloudwatch_instance_profile" {
  name = "cloudwatch-instance-profile"
  role = aws_iam_role.cloudwatch_role.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_attach" {
  role       = aws_iam_role.cloudwatch_role.name
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
}

````
## 2. Security Group
Ensure the security group includes ports for CloudWatch and Spring Boot app.

This is already done in the security group from the earlier configuration.

## 3. EC2 Instance with CloudWatch Agent
Add the CloudWatch agent installation and configuration in `user_data`.
````hcl
resource "aws_instance" "springboot_instance" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  key_name      = var.key_name
  security_groups = [
    aws_security_group.springboot_sg.name
  ]
  iam_instance_profile = aws_iam_instance_profile.cloudwatch_instance_profile.name

  user_data = <<-EOF
            #!/bin/bash
            # Update packages and install required software
            sudo yum update -y
            sudo yum install -y java-11-openjdk git amazon-cloudwatch-agent

            # Clone Spring Boot application repository
            git clone ${var.github_repo_url}
            cd your-springboot-repo # Replace with your repository name
            ./mvnw package
            nohup java -jar target/*.jar &

            # Create CloudWatch Logs configuration
            cat <<EOT > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
            {
              "logs": {
                "logs_collected": {
                  "files": {
                    "collect_list": [
                      {
                        "file_path": "/home/ec2-user/your-springboot-repo/logs/springboot.log",
                        "log_group_name": "SpringBootLogs",
                        "log_stream_name": "{instance_id}"
                      }
                    ]
                  }
                }
              }
            }
            EOT

            # Start CloudWatch Agent
            sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
              -a start -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
  EOF

  tags = {
    Name = "SpringBoot-EC2"
  }
}

````

## 4. Log Configuration in Spring Boot
Make sure your Spring Boot application logs to a file. Update your `application.properties` or `application.yml` file in the repository:
````properties
logging.file.path=logs
logging.file.name=springboot.log
````