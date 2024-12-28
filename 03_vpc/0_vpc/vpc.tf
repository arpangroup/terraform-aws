# VPC
resource "aws_vpc" "TF_VPC" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "TF_VPC"
  }
}

# Public Subnets
resource "aws_subnet" "TF_PUBLIC_SUBNET" {
  count  = 2
  vpc_id = aws_vpc.TF_VPC.id
  #cidr_block = "10.0.1.0/24"
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  #availability_zone      = "us-east-1a"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "tf-public-subnet-${count.index}"
  }
}

# Private Subnets
resource "aws_subnet" "TF_PRIVATE_SUBNET" {
  count  = 2
  vpc_id = aws_vpc.TF_VPC.id
  #cidr_block        = "10.0.5.0/24"
  cidr_block              = "10.0.${count.index + 10}.0/24"
  map_public_ip_on_launch = false
  #availability_zone = "us-east-1b"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "tf-private-subnet-${count.index}"
  }
}

# Internet Gateway for Public Subnets
resource "aws_internet_gateway" "TF_IGW" {
  vpc_id = aws_vpc.TF_VPC.id

  tags = {
    Name = "tf-main-igw"
  }
}

# Route Table for Public Subnets
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
resource "aws_route_table_association" "public_route_table_association" {
  count          = 2
  subnet_id      = aws_subnet.TF_PUBLIC_SUBNET[count.index].id
  route_table_id = aws_route_table.TF_PUBLIC_ROUTE_TABLE.id
}

######################################################
#                    NAT Gateway                     #
######################################################
# NAT Gateway for Private Subnets
resource "aws_eip" "TF_NAT_EIP" {
  vpc = true
  depends_on = [aws_internet_gateway.TF_IGW]

  tags = {
    Name = "tf-nat-eip"
  }
}

resource "aws_nat_gateway" "TF_NAT_GATEWAY" {
  allocation_id = aws_eip.TF_NAT_EIP.id
  subnet_id     = aws_subnet.TF_PUBLIC_SUBNET[*].id # NAT Gateway in the first public subnet
  depends_on    = [aws_internet_gateway.TF_IGW]

  tags = {
    Name = "tf-nat-gateway"
  }
}

# Route Table for Private Subnets
resource "aws_route_table" "TF_PRIVATE_ROUTE_TABLE" {
  vpc_id = aws_vpc.TF_VPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.TF_NAT_GATEWAY.id #destination
  }
  depends_on = [aws_internet_gateway.TF_IGW]

  tags = {
    Name = "tf-private-route-table"
  }
}

# Associate Route Table with Private Subnets
resource "aws_route_table_association" "TF_PRIVATE_ROUTE_ASSOCIATION" {
  count          = 2
  subnet_id      = aws_subnet.TF_PRIVATE_SUBNET[count.index].id
  route_table_id = aws_route_table.TF_PRIVATE_ROUTE_TABLE.id
}
######################################################

# Get availability zones
data "aws_availability_zones" "available" {
  state = "available"
}
