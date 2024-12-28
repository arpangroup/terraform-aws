output "vpc" {
  value = aws_vpc.TF_VPC.id
}

output "vpc_cidr_block" {
  value = aws_vpc.TF_VPC.cidr_block
}

output "public_subnets" {
  value = [
    for subnet in aws_subnet.TF_PUBLIC_SUBNET : {
      id                    = subnet.id
      cidr_block            = subnet.cidr_block
      aws_availability_zone = subnet.availability_zone
    }
  ]
}

output "private_subnets" {
  value = [
    for subnet in aws_subnet.TF_PRIVATE_SUBNET : {
      id                    = subnet.id
      cidr_block            = subnet.cidr_block
      aws_availability_zone = subnet.availability_zone
    }
  ]
}

output "security_group" {
  value = {
    id =  aws_security_group.TF_PUBLIC_SG.id
    name = aws_security_group.TF_PUBLIC_SG.name
    arn = aws_security_group.TF_PUBLIC_SG.arn
  }
}

output "internet_gateway_id" {
  value = aws_internet_gateway.TF_IGW.id
}
output "elastic_ip" {
  value = aws_eip.TF_NAT_EIP.id
}
output "nat_gateway" {
  value = aws_nat_gateway.TF_NAT_GATEWAY.id
}

output "network" {
  value = {
    id = aws_vpc.TF_VPC.id
    tags.Name = aws_vpc.TF_VPC.tags.Name
    cidr_block = aws_vpc.TF_VPC.cidr_block
    public_subnets = [
      for subnet in aws_subnet.TF_PUBLIC_SUBNET : {
        id                    = subnet.id
        cidr_block            = subnet.cidr_block
        aws_availability_zone = subnet.availability_zone
      }
    ]
    private_subnets = [
      for subnet in aws_subnet.TF_PRIVATE_SUBNET : {
        id                    = subnet.id
        cidr_block            = subnet.cidr_block
        aws_availability_zone = subnet.availability_zone
      }
    ]
    security_groups = [
      {
        id   = aws_security_group.TF_PUBLIC_SG.id
        name = aws_security_group.TF_PUBLIC_SG.name
        arn  = aws_security_group.TF_PUBLIC_SG.arn
      },
      {
        id   = aws_security_group.TF_ALB_SG.id
        name = aws_security_group.TF_ALB_SG.name
        arn  = aws_security_group.TF_ALB_SG.arn
      }
    ]
    internet_gateway_id = aws_internet_gateway.TF_IGW.id
    elastic_ip = aws_eip.TF_NAT_EIP.id
    nat_gateway = aws_nat_gateway.TF_NAT_GATEWAY.id
  }
}

