# EC2
1. **Change EC2 Instance Type?** 
   - yes possible for EBS backed instances. 
   - Stop the instance --> Settings --> Change Instance Type --> Start
2. Placement Group
3. [Burstable Instances](https://www.youtube.com/watch?v=1tUiAO7UyXc)

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
  count                  = 1
  ami                    = var.instance_ami_t2_micro
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.TF_SG.id]
  key_name               = aws_key_pair.TF_KEY_PAIR.key_name
  #user_data              = file("userdata.sh")

  /*user_data           = <<-EOF
                          #!/bin/bash
                          set -e  # Exit script on any error
                          yum update -y
                          yum install -y httpd
            
                          # Welcome message including Instance Metadata
                          echo "<h1>Welcome to Instance ${count.index}</h1><p>Host: $(hostname)</p>" > /var/www/html/index.html
                          echo "<p>VPC ID: ${var.vpc_id}</p>" >> /var/www/html/index.html
            
                          systemctl start httpd
                          systemctl enable httpd
                          EOF*/
  
  /*user_data              = <<-EOF
                          #!/bin/bash
                          set -e  # Exit script on any error
                          yum update -y
                          yum install -y httpd

                          # Welcome message including Instance Metadata
                          echo "<h1>Welcome to Instance ${count.index}</h1><p>Host: $(hostname)</p>" > /var/www/html/index.html
                          echo "<p>VPC ID: ${var.vpc_id}</p>" >> /var/www/html/index.html

                          # Fetch EC2 instance metadata
                          INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
                          PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
                          AVAILABILITY_ZONE=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone)
                          INSTANCE_TYPE=$(curl http://169.254.169.254/latest/meta-data/instance-type)

                          # Append EC2 metadata to the index.html
                          echo "<p>Instance ID: $INSTANCE_ID</p>" >> /var/www/html/index.html
                          echo "<p>Public IP: $PUBLIC_IP</p>" >> /var/www/html/index.html
                          echo "<p>Availability Zone: $AVAILABILITY_ZONE</p>" >> /var/www/html/index.html
                          echo "<p>Instance Type: $INSTANCE_TYPE</p>" >> /var/www/html/index.html

                          # Install the sysstat package to get CPU usage stats
                          yum install -y sysstat

                          # Get CPU usage using mpstat and append it to index.html
                          CPU_USAGE=$(mpstat 1 1 | grep "Average" | awk '{print $3}')
                          echo "<p>CPU Usage: $CPU_USAGE%</p>" >> /var/www/html/index.html

                          systemctl start httpd
                          systemctl enable httpd
                          EOF*/
  user_data = <<-EOF
              #!/bin/bash
              set -e  # Exit script on any error
              yum update -y
              yum install -y httpd

              # Create the HTML file
              cat <<HTML  > /var/www/html/index.html
              <!DOCTYPE html>
              <html>
              <head>
                  <title>EC2 Instance Metadata</title>
                  <style>
                      table {border-collapse: collapse; width: 100%;}
                      table, th, td {border: 1px solid black;}
                      th, td {padding: 8px; text-align: left;}
                  </style>
              </head>
              <body>

                <h2>EC2 Instance Metadata</h2>
                <table>
                    <tr><th>Metadata Field</th><th>Value</th></tr>
                    <tr><td>Instance ID</td><td>$(curl -s http://169.254.169.254/latest/meta-data/instance-id)</td></tr>
                    <tr><td>AMI ID</td><td>$(curl -s http://169.254.169.254/latest/meta-data/ami-id)</td></tr>
                    <tr><td>Public IP</td><td>$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)</td></tr>
                    <tr><td>Private IP</td><td>$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)</td></tr>
                    <tr><td>Instance Type</td><td>$(curl -s http://169.254.169.254/latest/meta-data/instance-type)</td></tr>
                    <tr><td>Availability Zone</td><td>$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</td></tr>
                    <tr><td>Security Groups</td><td>$(curl -s http://169.254.169.254/latest/meta-data/security-groups)</td></tr>
                    <tr><td>Region</td><td>$(curl -s http://169.254.169.254/latest/meta-data/placement/region)</td></tr>
                    <tr><td>IAM Role</td><td>$(curl -s http://169.254.169.254/latest/meta-data/iam/info | jq -r .InstanceProfileArn)</td></tr>
                </table>

              </body>
              </html>
              HTML

              systemctl start httpd
              systemctl enable httpd
              EOF


  metadata_options {
    http_tokens = "optional"   # allows both IMDSv1 and IMDSv2.
    http_endpoint = "enabled"  #["enabled", "disabled"] enables the metadata service.
  }


  tags = {
    Name = "WebApp-${count.index}"
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
