variable "vpc" {
  default = {
    "id" : "vpc-09c1e6099dea7c93e"
    "tags.Name": "TF_VPC"
    "cidr_block" : "10.0.0.0/16"
    "public_subnets" : [
      {
        "id" = "subnet-087681e703da3bf83"
        "cidr_block" = "10.0.0.0/24"
        "tags.Name" = "tf-public-subnet-0"
        "aws_availability_zone" = "us-east-1a"
      },
      {
        "id" = "subnet-0fafec6324c423988"
        "cidr_block" = "10.0.1.0/24"
        "tags.Name" = "tf-public-subnet-1"
        "aws_availability_zone" = "us-east-1b"
      },
    ]
    "private_subnets" : [
      {
        "id" = "subnet-0a64d49a5967081a6"
        "cidr_block" = "10.0.10.0/24"
        "tags.Name" = "tf-private-subnet-0"
        "aws_availability_zone" = "us-east-1a"
      },
      {
        "id" = "subnet-0af8b98cff14d458e"
        "cidr_block" = "10.0.11.0/24"
        "tags.Name" = "tf-private-subnet-1"
        "aws_availability_zone" = "us-east-1b"
      },
    ]
    "security_group" : {
      id   = "sg-059fe81990c4a879f"
      name =  "tf-public-sg"
      arn  =  "arn:aws:ec2:us-east-1:491085411576:security-group/sg-059fe81990c4a879f"
    }
  }
}


variable "key_pair" {
  default = "tf-key-pair"
}

variable "github_repo_url" {
  default = "https://github.com/arpangroup/hello-ecs-app.git"
}