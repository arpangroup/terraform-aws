resource "aws_instance" "springboot_ec2" {
  ami           = var.ami
  instance_type = "t2.micro"
  key_name      = var.key_name
  subnet_id     = var.vpc.public_subnets[0].id
  vpc_security_group_ids = [var.vpc.security_group.id]

  user_data = <<-EOF
    #!/bin/bash
    # Update packages
    yum update -y

    # Install Docker
    yum install -y docker
    service docker start
    usermod -a -G docker ec2-user

    # Install PostgreSQL client
    yum install -y postgresql

    # Pull and run PostgreSQL Docker container
    docker run -d --name postgresql-container -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=admin -e POSTGRES_DB=springbootdb -p 5432:5432 postgres:latest

    # Pull and run Spring Boot Docker container
    docker run -d --name springboot-app --link postgresql-container -p 80:8080 my-springboot-image:latest
  EOF

  tags = {
    Name = "SpringBoot-EC2"
  }
}