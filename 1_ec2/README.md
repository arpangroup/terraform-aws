# EC2 + UserData + KeyPair + SG

````hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "TF_KEY_PAIR" {
  key_name = "my-key-pair"
  # public_key = file("~/.ssh/id_rsa.pub") # Path to your public SSH key
  public_key = file("C:\\Users\\arpan\\.ssh\\id_rsa.pub")
}

resource "aws_instance" "web_app" {
  ami                    = "ami-0453ec754f44f9a4a"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.TF_SG.id] # optional: use default SG if we don't mentioned
  key_name               = aws_key_pair.TF_KEY_PAIR.key_name
  #user_data              = file("userdata.sh")
  user_data              = <<-EOF
                          #!/bin/bash
                          set -e  # Exit script on any error
                          yum update -y
                          yum install -y httpd
                          echo "Hello, World!" > /var/www/html/index.html
                          systemctl start httpd
                          systemctl enable httpd
                          EOF


  tags = {
    Name = "WebApp"
  }
}
````

## Generate a Key Pair (if you don’t have one):
````bash
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa
````

## Connect to the EC2 Instance via SSH:
````bash
ssh -i ~/.ssh/id_rsa ec2-user@<public-ip>
````
