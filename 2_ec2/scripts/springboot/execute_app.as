#!/bin/bash
set -e  # Exit immediately on error

# Logging commands for debugging
echo "Starting the Spring Boot app..." > /home/ec2-user/setup.log

# Run the Spring Boot application
nohup java -Dlogging.file.name=/home/ec2-user/api.log -jar /home/ec2-user/hello-ecs-app/target/*.jar & >> /home/ec2-user/setup.log 2>&1

echo "EC2 setup completed." >> /home/ec2-user/setup.log
