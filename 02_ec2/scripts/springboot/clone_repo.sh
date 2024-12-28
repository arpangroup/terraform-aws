#!/bin/bash
set -e  # Exit immediately on error

# Logging commands for debugging
echo "Cloning the repository..." > /home/ec2-user/setup.log

# Clone the repository
git clone ${var.github_repo_url} /home/ec2-user/hello-ecs-app >> /home/ec2-user/setup.log 2>&1

# Check if the repository was cloned successfully
if [ ! -d "/home/ec2-user/hello-ecs-app" ]; then
  echo "Failed to clone the repository" >> /home/ec2-user/setup.log
  exit 1
fi
