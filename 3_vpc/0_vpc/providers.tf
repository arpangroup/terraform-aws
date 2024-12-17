provider "aws" {
  region = "us-east-1"

  tags = {
    CreatedBy = "Terraform"
  }
}

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.56"
    }
  }

}