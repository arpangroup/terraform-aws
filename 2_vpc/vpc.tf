
# Create a VPC
resource "aws_vpc" "TF_VPC" {
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = {
    Name = "TF_VPC-${var.env}"
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
