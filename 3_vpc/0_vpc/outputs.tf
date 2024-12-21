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
