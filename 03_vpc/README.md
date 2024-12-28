## Terraform Code to Create a VPC
<img src="https://docs.aws.amazon.com/images/vpc/latest/userguide/images/how-it-works.png"/>

- **Subnets:**  A subnet must reside in a single Availability Zone
- **Routing:** Use route tables to determine where network traffic from your subnet or gateway is directed.
- **Gateways and endpoints:** A gateway connects your VPC to another network. For example
  - use an `internet gateway` to connect your VPC to the internet.
  - use a `NAT GAteway` to access the internet without exposing those resources to inbound internet traffic
  - Use a `VPC endpoint` to connect to AWS services privately, without the use of an internet gateway or NAT device.
- **Peering connections:** Use a VPC peering connection to route traffic between the resources in two VPCs.
- **raffic Mirroring:** [Copy network traffic](https://docs.aws.amazon.com/vpc/latest/mirroring/) from network interfaces and send it to security and monitoring appliances for deep packet inspection.
- **VPC Flow Logs:** A [flow log](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html) captures information about the IP traffic going to and from network interfaces in your VPC.


````hcl
provider "aws" {
  region = "us-east-1"
}
# Create a VPC
resource "aws_vpc" "TF_VPC" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "TF_VPC"
  }
}

# Create a public subnet
resource "aws_subnet" "TF_PUBLIC_SUBNET" {
  vpc_id                  = aws_vpc.TF_VPC.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a" # Specify availability zone
  map_public_ip_on_launch = true
  tags = {
    Name = "tf-public-subnet"
  }
}

# Create a private subnet
resource "aws_subnet" "TF_PRIVATE_SUBNET" {
  vpc_id            = aws_vpc.TF_VPC.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b" # Specify another availability zone
  tags = {
    Name = "tf-private-subnet"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "TF_IGW" {
  vpc_id = aws_vpc.TF_VPC.id
  tags = {
    Name = "tf-main-igw"
  }
}

# Create a route table for public subnet
resource "aws_route_table" "TF_PUBLIC_ROUTE_TABLE" {
  vpc_id = aws_vpc.TF_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.TF_IGW.id
  }

  tags = {
    Name = "tf-public-route-table"
  }
}

# Associate the public subnet with the route table
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.TF_PUBLIC_SUBNET.id
  route_table_id = aws_route_table.TF_PUBLIC_ROUTE_TABLE.id
}

# Create a security group for public access
resource "aws_security_group" "public_sg" {
  name        = "public_sg"
  description = "Security group for public access"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH access from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP access from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

````