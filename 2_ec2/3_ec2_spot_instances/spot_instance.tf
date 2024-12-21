# Spot Instance configuration
resource "aws_instance" "spot_instance" {
  ami                         = "ami-0b2f6494ff0b07a0e" # Replace with your desired AMI ID (e.g., Amazon Linux or Windows)
  instance_type               = "t2.micro" # Choose your instance type
  key_name                    = "my-key-pair" # Replace with your SSH key pair name
  subnet_id                   = ""
  security_groups             = [aws_security_group.ssh_sg.name]

  # Spot Instance configuration
  spot_price                  = "0.05" # Specify the maximum price you're willing to pay per hour (e.g., 0.05 USD)
  instance_interruption_behaviour = "terminate" # Action if the instance is interrupted
  wait_for_capacity_timeout    = "0"  # Don't wait for spot instance capacity



  # Tags
  tags = {
    Name = "Spot-Instance"
  }
}

output "spot_instance_public_ip" {
  value = aws_instance.spot_instance.public_ip
}