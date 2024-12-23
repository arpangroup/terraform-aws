#!/bin/bash
set -e  # Exit immediately on error

# Variables
REPO_URL="https://github.com/username/repository"   # Replace with your GitHub repository URL
BRANCH_NAME="branch-name"                          # Replace with your desired branch name
FILE_PATH="path/to/file.txt"                       # Replace with the file path you want to download

# Construct the raw URL for the file in the specific branch
# https://raw.githubusercontent.com/username/repository/branch-name/file-path
RAW_URL="https://raw.githubusercontent.com/username/repository/${BRANCH_NAME}/${FILE_PATH}"

# Use curl to download the file
curl -o $(basename $FILE_PATH) $RAW_URL


# Check if the download was successful
if [ $? -eq 0 ]; then
  echo "File downloaded successfully."
else
  echo "Failed to download file."
fi
