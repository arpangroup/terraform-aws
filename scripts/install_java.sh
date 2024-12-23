#!/bin/bash
set -e  # Exit immediately on error

# Install Java
sudo yum install -y java-21-amazon-corretto-headless

# Verify Java installation
#java -version >> $HOME/setup.log 2>&1
java -version