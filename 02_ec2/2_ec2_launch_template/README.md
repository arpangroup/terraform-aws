# AWS Launch Template

<image src="../../diagrams/launch_template.png" style="background-color:white"></image>

````hcl
provider "aws" {
  region = "us-east-1" # Replace with your desired region
}

resource "aws_launch_template" "example" {
  name_prefix   = "example-template-"
  description   = "Launch template for EC2 instances"

  # AMI and Instance Type
  image_id      = "ami-0c55b159cbfafe1f0" # Replace with your desired AMI ID
  instance_type = "t2.micro"

  # Key Pair for SSH access
  key_name      = "my-key-pair" # Replace with your existing key pair name

  # Security Groups
  vpc_security_group_ids = ["sg-0123456789abcdef0"] # Replace with your security group ID

  # User Data (Optional)
  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "Hello, World" > /var/www/html/index.html
              EOF
              )

  # Block device mappings (Optional)
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20
      volume_type = "gp2"
      delete_on_termination = true
    }
  }

  # Monitoring
  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "example-instance"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "launch_template_id" {
  value = aws_launch_template.example.id
}

````

## Videos
- [EC2 Launch Template - Part 17](https://www.youtube.com/watch?v=94b-SD2K8qk&list=PL7iMyoQPMtAPVSnMZOpptxGoPqwK1piC6&index=17)
- 