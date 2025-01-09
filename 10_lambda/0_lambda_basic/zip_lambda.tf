# Create Zip file locally
# zip ./lambda_function.zip ./lambda_function.py
resource "null_resource" "ZIP_LAMBDA" {
  provisioner "local-exec" {
    command = "echo CurrentDirectory: %CD% && zip ./lambda_function.zip ./lambda_function.py"
  }
}