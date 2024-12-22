
######################################################
#                    NAT Gateway                     #
######################################################
# NAT Gateway for Private Subnets
resource "aws_eip" "TF_NAT_EIP" {
  vpc = true

  tags = {
    Name = "tf-nat-eip"
  }
}

resource "aws_nat_gateway" "TF_NAT_GATEWAY" {
  allocation_id = aws_eip.TF_NAT_EIP.id
  subnet_id     = var.vpc.private_subnets[*].id

  tags = {
    Name = "tf-nat-gateway"
  }
}

# Route Table for Private Subnets
resource "aws_route_table" "TF_PRIVATE_ROUTE_TABLE" {
  vpc_id = var.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.TF_NAT_GATEWAY.id #destination
  }
  depends_on = [var.vpc.internet_gateway_id]

  tags = {
    Name = "tf-private-route-table"
  }
}

# Associate Route Table with Private Subnets
resource "aws_route_table_association" "TF_PRIVATE_ROUTE_ASSOCIATION" {
  count          = 2
  subnet_id      = var.vpc.private_subnets[*].id
  route_table_id = aws_route_table.TF_PRIVATE_ROUTE_TABLE.id
}