#!/bin/bash
set -e  # Exit immediately on error

# Variables
REPO_URL="https://github.com/arpangroup/config-infra.git"   # Replace with your GitHub repository URL
BRANCH_NAME="branch_scripts"               # Replace with your desired branch name
LOCAL_DIR="scripts"                        # Directory to clone the repo
FILE_PATH="${var.file_path}"                            # Pass the FILE_PATH from Terraform variable


# Clone the repository and checkout the specific branch
git clone --branch $BRANCH_NAME --single-branch $REPO_URL $FILE_PATH

# Check if cloning was successful
if [ $? -eq 0 ]; then
  echo "Repository cloned successfully."
else
  echo "Failed to clone the repository."
  exit 1
fi

# Navigate to the cloned repository directory
cd $LOCAL_DIR

# List the contents of the repository (optional)
echo "Listing files in the repository:"
ls -al

# You can now access files from the branch
# Example: Copying a specific file to the current directory
# Copy the specific file to the parent directory
cp $FILE_PATH ../$(basename $FILE_PATH)


# Check if the file copy was successful
if [ $? -eq 0 ]; then
  echo "File copied successfully."
else
  echo "Failed to copy the file."
fi