# Create Zip file locally
# zip ./lambda_function.zip ./lambda_function.py
resource "null_resource" "ZIP_LAMBDA" {
  provisioner "local-exec" {
    command     = "echo CurrentDirectory: $(pwd) && zip ./lambda_function.zip ./lambda_function.py"
    interpreter = ["C:\\Program Files\\Git\\bin\\bash.exe", "-c"]
  }
}