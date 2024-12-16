provider "aws" {
  #   shared_credentials_file = "$HOME/.aws/credentials"
  #   profile                 = "default"
  region = "us-east-1"

  tags = {
    CreatedBy = "Terraform"
  }
}