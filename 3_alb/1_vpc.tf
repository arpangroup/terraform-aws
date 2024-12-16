# Create a VPC
resource "aws_vpc" "TF_VPC" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "TF_VPC"
  }
}

# Create two public subnets
resource "aws_subnet" "TF_PUBLIC_SUBNET" {
  count      = 2
  vpc_id     = aws_vpc.TF_VPC.id
  cidr_block = "10.0.${count.index}.0/24"
  # cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  #availability_zone      = "us-east-1a"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "tf-public-subnet"
  }
}

# Create a private subnet
resource "aws_subnet" "TF_PRIVATE_SUBNET" {
  vpc_id            = aws_vpc.TF_VPC.id
  cidr_block        = "10.0.5.0/24"
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

# Associate Route Table with Subnets
resource "aws_route_table_association" "public_association" {
  count          = 2
  subnet_id      = aws_subnet.TF_PUBLIC_SUBNET[count.index].id
  route_table_id = aws_route_table.TF_PUBLIC_ROUTE_TABLE.id
}

# Get availability zones
data "aws_availability_zones" "available" {
  state = "available"
}
