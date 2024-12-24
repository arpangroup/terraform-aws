# EC2 Log to Cloudwatch using Terraform
1. Install CloudWatch Agent
   - Install Agent (`yum install amazon-cloudwatch-agent -y`)
   - Create a CloudWatch Agent Configuration File 
   - Start the CloudwatchAgent
2. Setup InstanceProfile (STS Role + Policy)


## 1. Install CloudWatch Agent
````hcl
resource "aws_instance" "example" {
  ami           = "ami-01816d07b1128cd2d"
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.cloudwatch_instance_profile.name

  user_data = <<-EOF
      #!/bin/bash
      # Install CloudWatch Agent
      sudo yum install -y amazon-cloudwatch-agent
      
      # Create CloudWatch Agent Configuration
      cat <<EOC > /opt/aws/amazon-cloudwatch-agent/bin/config.json
      {
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
                },
                {
                  "file_path": "/home/ec2-user/api.log",
                  "log_group_name": "spring-app-logs",
                  "log_stream_name": "{instance_id}-api-log",
                  "timestamp_format": "%Y-%m-%dT%H:%M:%S.%fZ",
                  "timezone": "UTC"
                }
              ]
            }
          }
        }
      }
      EOC
      
      # Start the CloudWatch Agent
      sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
        -a fetch-config \
        -m ec2 \
        -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json \
        -s
      EOF
      }
````


## 2. Setup InstanceProfile (STS Role + Policy)
