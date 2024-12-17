## EC2 Logging to CloudWatch
To enable EC2 instance logs (like system logs or application logs) to be sent to `Amazon CloudWatch` using Terraform, you need to do the following:
1. Install and configure the CloudWatch agent on the EC2 instance.
2. Define an IAM role with policies to allow CloudWatch logging.
3. Attach the role to the EC2 instance.
4. Use a user data script to install and start the CloudWatch agent.

````hcl
provider "aws" {
  region = "us-east-1"
}

# IAM Role and Policy for CloudWatch Logs
resource "aws_iam_role" "ec2_cloudwatch_role" {
  name = "ec2-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs_attach" {
  role       = aws_iam_role.ec2_cloudwatch_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-cloudwatch-instance-profile"
  role = aws_iam_role.ec2_cloudwatch_role.name
}

# Security Group
resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Allow SSH and HTTP"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance with User Data to Install CloudWatch Agent
resource "aws_instance" "ec2_instance" {
  ami                         = "ami-0c55b159cbfafe1f0" # Replace with your AMI ID
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  key_name                    = "my-key-pair" # Replace with your key pair name

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y amazon-cloudwatch-agent
              cat <<CWAGENTCONFIG > /opt/aws/amazon-cloudwatch-agent/bin/config.json
              {
                "agent": {
                  "run_as_user": "root"
                },
                "logs": {
                  "logs_collected": {
                    "files": {
                      "collect_list": [
                        {
                          "file_path": "/var/log/messages",
                          "log_group_name": "ec2-system-logs",
                          "log_stream_name": "{instance_id}/messages",
                          "timezone": "UTC"
                        },
                        {
                          "file_path": "/var/log/cloud-init.log",
                          "log_group_name": "ec2-cloud-init-logs",
                          "log_stream_name": "{instance_id}/cloud-init.log",
                          "timezone": "UTC"
                        }
                      ]
                    }
                  }
                }
              }
              CWAGENTCONFIG

              sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
                -a fetch-config \
                -m ec2 \
                -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json \
                -s
              EOF

  tags = {
    Name = "ec2-cloudwatch-instance"
  }
}

output "instance_id" {
  value = aws_instance.ec2_instance.id
}
````
- User Data Script:
  - Installs the CloudWatch agent.
  - Configures CloudWatch agent to collect logs (e.g., `/var/log/messages` and `/var/log/cloud-init.log`).
  - Starts the CloudWatch agent with the specified configuration.

## CloudWatch Log Group: 
Logs are automatically sent to specified `log groups` (`ec2-system-logs` and `ec2-cloud-init-logs`).