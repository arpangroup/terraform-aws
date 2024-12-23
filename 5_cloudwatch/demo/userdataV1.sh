#!/bin/bash
set -e  # Exit immediately on error

# Set the HOME environment variable explicitly
export HOME=/home/ec2-user

# Variables
LOG_FILE="$HOME/setup.log"
RAW_URL="https://raw.githubusercontent.com/arpangroup/config-infra"   # https://raw.githubusercontent.com/arpangroup/config-infra/branch_scripts/install_java.sh
BRANCH_NAME="branch_scripts"               # Replace with your desired branch name
#GITHUB_REPO_URL=${var.github_repo_url}
GITHUB_REPO_URL="https://github.com/arpangroup/hello-ecs-app.git"
APP_PATH=$HOME/myapp


# Logging commands for debugging
echo "Starting EC2 setup..." > $LOG_FILE
sudo yum update -y >> $LOG_FILE 2>&1
sudo yum install -y git >> $LOG_FILE 2>&1
SCRIPT_BASE_URL=${RAW_URL}/${BRANCH_NAME}


# Download and run the install_java.sh script
echo "Downloading and executing Java installation script from ${SCRIPT_BASE_URL}/install_java.sh..." >> $LOG_FILE
curl -sSL ${SCRIPT_BASE_URL}/install_java.sh | bash >> $LOG_FILE 2>&1


# Clone the repo
echo "Cloning repository [$GITHUB_REPO_URL] to [$APP_PATH]..." >> $LOG_FILE
git clone ${GITHUB_REPO_URL} ${APP_PATH} >> $LOG_FILE 2>&1


# Download and run the maven_build.sh script
echo "Maven build and packaging...." >> $LOG_FILE
curl -sSL ${SCRIPT_BASE_URL}/maven_build.sh | bash >> $LOG_FILE 2>&1



# Run the Spring Boot application
echo "Starting the Spring Boot app..." >> $LOG_FILE
nohup java -Dlogging.file.name=$HOME/api.log -jar $APP_PATH/target/*.jar & >> $LOG_FILE 2>&1
#nohup java -jar target/*.jar &  >> $LOG_FILE 2>&1

echo "EC2 setup completed." >> $$LOG_FILE

