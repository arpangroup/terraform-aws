# AWS ALB to balance load between two EC2 instances
<image src="../diagrams/alb_to_ec2.png"/>

## Steps:
1. VPC + IGW + RT 
   - 2 public subnet 
   - 2 private subnet (private subnets we are not using for simplicity)
   - IGW to route the traffic from internet to public subnet
   - RouteTable ==> IGW for public subnets
2. SecurityGroups
   - one for ALB 
   - other for EC2 targets (**Allow traffic only from the ALB**)
3. EC2 instances
   - 2 EC2 instances for 2 public subnet (i.e. different AZ) 
4. Target group for above EC2 instances
5. ALB to allow take request from client on port 80 and forward the request to TG
