#!/bin/bash
set -e  # Exit immediately on error

# Logging commands for debugging
echo "Making mvnw executable..." > /home/ec2-user/setup.log

# Change to the project directory
cd /home/ec2-user/hello-ecs-app

# Make mvnw script executable
chmod +x ./mvnw >> /home/ec2-user/setup.log 2>&1

# Running Maven package
echo "Running Maven package..." >> /home/ec2-user/setup.log
./mvnw package >> /home/ec2-user/setup.log 2>&1
