## Create EC2 using Terraform

### Step1; Create Provider

`provider.tf`:
````hcl
provider "aws" {
  region = "us-east-1"
  # access_key = "<YOUR_ACCESS_KEY>"
  # secret_key = "<YOR_SECRET_KEY>"
}
````
But Hard coding of `access_key` and `secret_key` is not recommended, instead use `aws configure`
````console
aws configure

AWS Access Key ID [****************DWEV]:<YOUR_ACCESS_KEY>
AWS Secret Key [****************DWEV]:<YOR_SECRET_KEY>
````

### Step2: Download provider specific dependency
````console
terraform init

Initializing the backend...
Initializing provider plugins...
- Finding latest version of hashicorp/aws...
- Installing hashicorp/aws v5.81.0...
````
It will create couples of file and folder inside your directory like:
- .terraform directory
- .terraform.lock.hcl

### Format/Beautify the code
````bash
terraform fmt
````

### Check whether the code syntax are valid or not
````bash
terraform validate
````

### Step3: Create the EC2 instance

#### EC2 with default security group  
````hcl
resource "aws_instance" "web-app" {
  ami = var.instance_ami_t2_micro
  instance_type = var.instance_type
  count = 1 # optional

  tags = {
    Name = "HelloWorld"
  }
}
````

#### EC2 with custom security group  
````hcl
resource "aws_instance" "web-app" {
  ami           = var.instance_ami_t2_micro
  instance_type = var.instance_type
  security_groups = ["aws_security_group.TF_SG.name"]
  user_data = <<-EOF
              #!/bin/bash
          set -e  # Exit script on any error
            yum update -y
            yum install -y httpd
              echo "Hello, World!" > /var/www/html/index.html
              systemctl start httpd
             systemctl enable httpd
              EOF
  
  tags = {
    Name = "HelloWorld"
  }
}
````

### Step3: Generate a Key Pair (if you don’t have one):
````bash
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa
or
ssh-keygen -t rsa -b 2048 -f id_rsa
````
Make sure `~/.ssh/id_rsa.pub` contains your public key.

### Connect to the EC2 Instance via SSH:
````bash
ssh -i ~/.ssh/id_rsa ec2-user@<public-ip>
````