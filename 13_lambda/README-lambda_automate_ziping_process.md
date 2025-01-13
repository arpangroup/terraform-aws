## Automate the process of zipping the Lambda code

### 1. Automating with a Shell Script
````bash
#!/bin/bash

ZIP_NAME="lambda_function.zip"
FILES="lambda_function.py"

echo "Creating $ZIP_NAME..."
zip $ZIP_NAME $FILES
echo "$ZIP_NAME created successfully."
````

Make the script executable and run it:
````bash
chmod +x zip_lambda.sh
./zip_lambda.sh
````


### 2. Automating with a Python Script
````python
import os
import zipfile

def create_zip(zip_name, files):
    with zipfile.ZipFile(zip_name, 'w') as zipf:
        for file in files:
            zipf.write(file, os.path.basename(file))
    print(f"{zip_name} created successfully.")

# Files to include in the zip
files_to_zip = ["lambda_retry_sync.py"]

# Output zip file name
zip_name = "lambda_function.zip"

# Create the zip file
create_zip(zip_name, files_to_zip)
````

Run the script:
````bash
python automate_zip.py
````

### 3. Automating in Terraform
Use the `local-exec` provisioner in Terraform to automate zipping during deployment:
````hcl
# local-exec provisioner in Terraform to automate zipping
resource "null_resource" "zip_lambda" {
  provisioner "local-exec" {
    command = "zip lambda_function.zip lambda_retry_sync.py"
  }
}

# Actual Lambda Function
resource "aws_lambda_function" "example" {
  depends_on   = [null_resource.zip_lambda]
  function_name = "example_lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  filename      = "lambda_function.zip"

  environment {
    variables = {
      KEY = "value"
    }
  }
}
````

### 4. Automating with CI/CD Pipelines:
In a CI/CD pipeline (e.g., GitHub Actions, Jenkins, GitLab CI), you can add steps to zip the Lambda code before deployment.
````yaml
name: Deploy Lambda

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Zip Lambda code
        run: zip lambda_function.zip lambda_retry_sync.py

      - name: Deploy using Terraform
        run: terraform apply -auto-approve
````
