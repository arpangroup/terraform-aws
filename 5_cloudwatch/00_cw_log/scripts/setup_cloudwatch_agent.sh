#!/bin/bash

# Update the system
sudo yum update -y

# Install the Amazon CloudWatch Agent
sudo yum install -y amazon-cloudwatch-agent

# Create CloudWatch Agent configuration
# `cat <<CWAGENTCONFIG`: Begins a here-document, allowing multiple lines of text to be written into a file.
# File Path: `/opt/aws/amazon-cloudwatch-agent/bin/config.json` is where the configuration is saved.
# Logs Collection: Specifies log files to monitor
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

# Start the CloudWatch Agent with the configuration
# `amazon-cloudwatch-agent-ctl`: A command-line tool to manage the CloudWatch Agent
# `-a fetch-config`: Fetches the configuration specified by the `-c` option.
# `-m ec2`: Indicates that the agent is running on an EC2 instance.
# `-c file:/path/to/config.json`: Specifies the path to the configuration file.
# `-s`: Starts the CloudWatch Agent after loading the configuration.
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json \
  -s
