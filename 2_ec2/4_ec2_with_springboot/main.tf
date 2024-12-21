resource "aws_instance" "springboot_instance" {
  ami           = var.ami
  instance_type = "t2.micro"
  key_name      = var.key_name
  subnet_id     = var.vpc.public_subnets[0].id
  vpc_security_group_ids = [var.vpc.security_group.id]


  user_data = <<-EOF
            #!/bin/bash
            set -e  # Exit immediately on error

            # Set the HOME environment variable explicitly
            export HOME=/home/ec2-user

            # Logging commands for debugging
            echo "Starting EC2 setup..." > $HOME/setup.log
            sudo yum update -y >> $HOME/setup.log 2>&1

            # Install dependencies
            sudo yum install -y java-21-amazon-corretto-headless >> $HOME/setup.log 2>&1
            sudo yum install -y git >> $HOME/setup.log 2>&1

            # Verify Java installation
            java -version >> $HOME/setup.log 2>&1

            # Clone the repository
            echo "Cloning repository..." >> $HOME/setup.log
            git clone ${var.github_repo_url} $HOME/hello-ecs-app >> $HOME/setup.log 2>&1

            # Check if the repository was cloned successfully
            if [ ! -d "$HOME/hello-ecs-app" ]; then
              echo "Failed to clone the repository" >> $HOME/setup.log
              exit 1
            fi

            # Change to the project directory
            cd $HOME/hello-ecs-app
            echo "Making mvnw executable..." >> $HOME/setup.log
            chmod +x ./mvnw  # Make mvnw script executable


            # Running Maven package
            echo "Running Maven package..." >> $HOME/setup.log
            ./mvnw package >> $HOME/setup.log 2>&1

            # Run the Spring Boot application
            echo "Starting the Spring Boot app..." >> $HOME/setup.log
            nohup java -Dlogging.file.name=$HOME/api.log -jar target/*.jar & >> $HOME/setup.log 2>&1
            #nohup java -jar target/*.jar &  >> $HOME/setup.log 2>&1

            echo "EC2 setup completed." >> $HOME/setup.log
  EOF

  tags = {
    Name = "SpringBoot-EC2"
  }
}

output "ec2_public_ip" {
  value = aws_instance.springboot_instance.public_ip
  description = "Public IP address of the EC2 instance"
}