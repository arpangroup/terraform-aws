#!/bin/bash
set -e  # Exit immediately on error
echo "Installling Java........."

# Install Java
sudo yum install -y
sudo yum install -y java-21-amazon-corretto-headless

# Verify Java installation
#java -version >> $HOME/setup.log 2>&1
java -version