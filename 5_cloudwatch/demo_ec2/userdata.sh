#!/bin/bash
set -e  # Exit immediately on error

# Set the HOME environment variable explicitly
export HOME=/home/ec2-user

# Logging commands for debugging
echo "Starting EC2 setup..." > $HOME/setup.log
sudo yum update -y >> $HOME/setup.log 2>&1



###########################################################
#                  INSTALL JAVA                           #
###########################################################
# Embed the Java installation script content
echo "Running Java installation script..." >> $HOME/setup.log

# Install Java
echo "Install JDK......." >> $HOME/setup.log
sudo yum install -y java-21-amazon-corretto-headless >> $HOME/setup.log 2>&1

# Verify Java installation
java -version >> $HOME/setup.log 2>&1



###########################################################
#            INSTALL CloudWatch Agent                     #
###########################################################
echo "Running CloudWatch installation script..." >> $HOME/setup.log

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
echo "Start the CloudWatch Agent with the configuration..." >> $HOME/setup.log
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json \
  -s


sudo systemctl status amazon-cloudwatch-agent >> $HOME/setup.log 2>&1
echo "CloudWatch Installation Done......." >> $HOME/setup.log

###########################################################
#            INSTALL CloudWatch Agent                     #
###########################################################