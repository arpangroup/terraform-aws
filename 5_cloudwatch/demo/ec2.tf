provider "aws" {
  region = "us-east-1"
}

# EC2 Instance
resource "aws_instance" "TF_WEB_APP" {
  ami           ="ami-01816d07b1128cd2d"
  instance_type = "t2.micro"
  #iam_instance_profile = aws_iam_instance_profile.TF_ec2_instance_profile.name
  subnet_id                   = var.vpc.public_subnets[0].id
  vpc_security_group_ids      = [var.vpc.security_group.id]
  key_name                    = var.key_pair

  user_data = file("./scripts/userdata.sh")

  tags = {
    Name = "tf-webapp"
  }
}


output "instance_id" {
  value = aws_instance.TF_WEB_APP.public_ip
}