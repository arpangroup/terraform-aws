#!/bin/bash

# Debug: Print current working directory
echo "Current directory: $(pwd)"

# Directory containing the Python files
LAMBDA_CODE_DIR="./lambda_codes"

# Directory to store the zip files
ARCHIVES_DIR="$LAMBDA_CODE_DIR/archives"

# Check if the lambda_codes directory exists
if [ ! -d "$LAMBDA_CODE_DIR" ]; then
  echo "Error: Directory $LAMBDA_CODE_DIR does not exist."
  exit 1
fi

# Delete the archives directory if it exists
if [ -d "$ARCHIVES_DIR" ]; then
  echo "Deleting existing archives directory: $ARCHIVES_DIR"
  rm -rf "$ARCHIVES_DIR"
fi

# Create a new archives directory
echo "Creating new archives directory: $ARCHIVES_DIR"
mkdir -p "$ARCHIVES_DIR"

# Loop through each file and create a zip file
for file in handle_error.py notify_customer.py prepare_shipment.py process_payment.py validate_order.py; do
  # Check if the file exists
  if [ ! -f "$LAMBDA_CODE_DIR/$file" ]; then
    echo "Error: File $LAMBDA_CODE_DIR/$file does not exist."
    exit 1
  fi

  # Create the zip file
  zip_name="${file%.py}.zip"
  echo "Zipping $file into $ARCHIVES_DIR/$zip_name"
  zip -j "$ARCHIVES_DIR/$zip_name" "$LAMBDA_CODE_DIR/$file"
done