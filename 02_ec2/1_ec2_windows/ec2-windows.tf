provider "aws" {
  region = "us-east-1" # Replace with your desired AWS region
}

# Security Group to allow RDP access
resource "aws_security_group" "TF_WINDOWS_SG" {
  name        = "tf_windows_sg"
  description = "Allow RDP access for Windows EC2"

  # Allow RDP (port 3389)
  ingress {
    description = "RDP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict to your IP for security
  }

  # Allow HTTP (port 80)
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to the internet; restrict for production
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Windows EC2 Instance
resource "aws_instance" "windows_instance" {
  count         = 2
  ami = "ami-0b2f6494ff0b07a0e" # Windows Server 2019 AMI (replace with region-specific Windows AMI)
  instance_type = "t2.micro"
  key_name = "my-key-pair" # Replace with your key pair
  vpc_security_group_ids = [aws_security_group.TF_WINDOWS_SG.id]

  # User Data (PowerShell Script)
  user_data = <<-EOF
              <powershell>
              ## Rename the computer based on the instance index
              Rename-Computer -NewName "WinServer-${count.index}" -Force -PassThru

              ## Create a new user
              #net user AdminUser "P@ssw0rd123!" /add
              #net localgroup Administrators AdminUser /add

              ## Install IIS (Web Server)
              Install-WindowsFeature -Name Web-Server -IncludeManagementTools

              ## Start the IIS service
              Start-Service -Name W3VC

              ## Create a simple index.html
              #New-Item -Path "C:\\inetpub\\wwwroot\\index.html" -ItemType File -Value "<h1>Hello from Windows EC2</h1>"

              ## Setup a basic HTML page to test the web server
              $webpagePath = "C:\inetpub\wwwroot\index.html"
              @"
              <html>
              <head>My Windows Web Server - Demo</head>
              <body>
                <h1>Welcome to My Webserver!</h1>
                <p>This is a test page served by Internet Information Service (IIS) on Windows server EC2 instance.</p>
              </body>
              </html>
              "@ | Out-File -FilePath $webpagePath

              ## Restart the IIS service to apply changes
              Restart-Service -Name W3VC

              ## Restart the instance
              #Restart-Computer -Force
              </powershell>
              EOF

  tags = {
    Name = "Windows-EC2-Instance-${count.index}"
  }
}

output "instance_public_dns" {
  value = aws_instance.windows_instance[*].public_dns
}

output "rdp_connection" {
  value = "Connect using RDP to ${aws_instance.windows_instance.public_dns} with your key pair."
}
