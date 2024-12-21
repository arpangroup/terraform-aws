#!/bin/bash
set -e  # Exit immediately on error

# Set the HOME environment variable explicitly
export HOME=/home/ec2-user

# Logging commands for debugging
echo "Starting EC2 setup..." > /home/ec2-user/setup.log

# Download and run the install_java.sh script
curl -O ${var.s3_bucket_url}/install_java.sh
chmod +x install_java.sh
./install_java.sh

# Download and run the clone_repo.sh script
curl -O ${var.s3_bucket_url}/clone_repo.sh
chmod +x clone_repo.sh
./clone_repo.sh

# Download and run the maven_build.sh script
curl -O ${var.s3_bucket_url}/maven_build.sh
chmod +x maven_build.sh
./maven_build.sh

# Download and run the execute_app.sh script
curl -O ${var.s3_bucket_url}/execute_app.sh
chmod +x execute_app.sh
./execute_app.sh

echo "EC2 setup completed." >> /home/ec2-user/setup.log