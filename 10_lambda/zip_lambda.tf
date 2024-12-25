resource "null_resource" "zip_lambda" {
  provisioner "local-exec" {
    command = "zip lambda_function.zip lambda_function.py"
  }
}
