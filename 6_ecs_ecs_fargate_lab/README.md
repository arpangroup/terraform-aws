## ECS
- [Deploy an Application to Amazon ECS With EC2 | Docker | ECR | Fargate | Load balancer](https://www.youtube.com/watch?v=6Hj-stf51Bc&list=PLqoUmUbJ_zDHPwK-ZWATXiYrUXwWkLY65&index=1)


## Step1: Create & Publish Docker Image
- Install Docker
- Build Docker Image
- Test/Validate Docker Image
- Push image into ECR

## Step2: Create Networking
1. Providers + Backend state 
2. VPC + subnet + IGW + RT 
3. Security Group (depends on VPC)
4. [TargetGroup](../README-TargetGroup.md) (depends on VPC)
5. Load Balancer  (depends on SG, SUBNET, TG)

## Step3: IAM Roles
1. IAM Role
2. IAM Policy (depends on IAM_ROLE)

## Step4: Create ECS Cluster
1. Create The Cluster
2. Create Task Definition (depends on IAM_ROLE)
3. Create Service (depends on CLUSTER, TF_TASK_DEFINITION, TF_IAM_ROLE, ALB_LISTENER)

## Step5:
- Validation

