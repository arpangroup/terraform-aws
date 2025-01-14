resource "null_resource" "ZIP_LAMBDA" {
  provisioner "local-exec" {
    command     = "bash ./zip_lambdas.sh"
    interpreter = ["C:\\Program Files\\Git\\bin\\bash.exe", "-c"]
  }
}