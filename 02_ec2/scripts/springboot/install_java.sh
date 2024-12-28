#!/bin/bash
set -e  # Exit immediately on error

# Logging commands for debugging
echo "Installing Java and dependencies..." > /home/ec2-user/setup.log

# Install dependencies
sudo yum update -y >> /home/ec2-user/setup.log 2>&1
sudo yum install -y java-21-amazon-corretto-headless >> /home/ec2-user/setup.log 2>&1
sudo yum install -y git >> /home/ec2-user/setup.log 2>&1

# Verify Java installation
java -version >> /home/ec2-user/setup.log 2>&1
