# terraform {
#   backend "s3" {
#     bucket = ""
#     region = ""
#     key = ""
#     encrypt = true
#   }
#   required_version = ">=0/13.0"
#   required_providers {
#     aws = {
#       version = ">= 2.7.0"
#       source  = "hashicorp/aws"
#     }
#   }
# }