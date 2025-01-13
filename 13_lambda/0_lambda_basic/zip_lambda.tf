# Create Zip file locally
# zip ./lambda_function.zip ./lambda_retry_sync.py
resource "null_resource" "ZIP_LAMBDA" {
  provisioner "local-exec" {
#     command = "echo CurrentDirectory: %CD% && zip ./lambda_function.zip ./lambda_retry_sync.py"

    command     = "echo CurrentDirectory: $(pwd) && zip ./lambda_function.zip ./lambda_function.py"
    interpreter = ["C:\\Program Files\\Git\\bin\\bash.exe", "-c"]
  }
}