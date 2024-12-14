# Create a VPC
resource "aws_vpc" "example_vpc" {
     cidr_block           = "10.0.0.0/16"
     enable_dns_support   = true
     enable_dns_hostnames = true
     tags = {
        Name = "example-vpc"
    }
}

# Create Subnets
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.example_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.example_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a" # Adjust to your availability zone
  tags = {
    Name = "private-subnet"
  }
}

# Create an Internet Gateway: Allows the public subnet to connect to the internet.
resource "aws_internet_gateway" "example_igw" {
  vpc_id = aws_vpc.example_vpc.id
  tags = {
    Name = "example-igw"
  }
}

# Create a Route Table: 
# A public route table with a route to the internet via the Internet Gateway
# Association between the public route table and the public subnet.
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.example_vpc.id
  tags = {
    Name = "public-route-table"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "public_route_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create a Default Route for Internet Gateway
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.example_igw.id
}