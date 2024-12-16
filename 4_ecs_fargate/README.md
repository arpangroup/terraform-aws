## ECS


- [Deploy an Application to Amazon ECS With EC2 | Docker | ECR | Fargate | Load balancer](https://www.youtube.com/watch?v=6Hj-stf51Bc&list=PLqoUmUbJ_zDHPwK-ZWATXiYrUXwWkLY65&index=1)
- [Take full control of ecs fargate using terraform](https://www.youtube.com/watch?v=7S7IEATzn3c)

# hello-ecs
- ECS
- ALB
- CloudWatch logs via docker plugin
- ElastiCache redis

This is not meant for production. For speed of deployments and lower costs, resources are deployed into public subnets. Security Groups are in place to lock down access, but ideally the resources are deployed into private subnets with a NAT Gateway

This is a basic example. If you're interested in more comprehensive ECS customization, includin
- spot instances
- automatic draining of containers
- autoscaling
- modularization of components
See https://github.com/ericdahl/tf-ecs



## Step1:
- Create Provider + VPC + SecurityGroup
- Create The Cluster
- Install Docker
- Build Docker Image


## Step2:
- Creating ECR
- Login to ECR
- Tag existing image as AWS ECR repo
- Push image into ECR

## Step3:
- Creating Load Balancer

## Step4:
- Create Task Definition
- Create ECS Cluster
- Create Service

## Step5:
- Validation